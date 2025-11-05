import SwiftUI

// MARK: - Zoom Pan Scroll View Wrapper
struct ZoomPanScrollViewWrapper: View {
    var config: ZoomConfig
    @State private var resetTrigger = UUID()
    
    var body: some View {
        ZStack {
            // Fondo del mapa
            Color.routePanelGreen.opacity(0.3)
            
            ZoomPanScrollViewWrapperInternal(
                config: config,
                resetTrigger: resetTrigger
            )
            
            // Botón flotante para resetear zoom
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        resetTrigger = UUID()
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.accessibleLime)
                            .background(
                                Circle()
                                    .fill(Color.routeDarkGreen)
                                    .frame(width: 44, height: 44)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                    .accessibilityLabel("Ver mapa completo")
                    .accessibilityHint("Doble toque para resetear el zoom y ver el mapa completo")
                }
                Spacer()
            }
        }
    }
}

// MARK: - Internal Wrapper
struct ZoomPanScrollViewWrapperInternal: UIViewRepresentable {
    var config: ZoomConfig
    var resetTrigger: UUID
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = config.minScale
        scrollView.maximumZoomScale = config.maxScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        
        // Configurar content inset para overscroll
        scrollView.contentInset = UIEdgeInsets(
            top: config.extraPanInset,
            left: config.extraPanInset,
            bottom: config.extraPanInset,
            right: config.extraPanInset
        )
        
        // Crear hosting controller para el contenido SwiftUI
        let hostingController = UIHostingController(rootView: MapContent())
        hostingController.view.backgroundColor = .clear
        context.coordinator.hostingController = hostingController
        
        // Crear un wrapper view para la rotación
        let rotationWrapper = UIView()
        rotationWrapper.backgroundColor = .clear
        rotationWrapper.addSubview(hostingController.view)
        
        // Agregar el wrapper al scroll view
        scrollView.addSubview(rotationWrapper)
        rotationWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints del wrapper
        NSLayoutConstraint.activate([
            rotationWrapper.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rotationWrapper.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rotationWrapper.widthAnchor.constraint(equalToConstant: 1000),
            rotationWrapper.heightAnchor.constraint(equalToConstant: 800)
        ])
        
        // Constraints del contenido dentro del wrapper
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: rotationWrapper.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: rotationWrapper.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: rotationWrapper.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: rotationWrapper.bottomAnchor)
        ])
        
        // Guardar referencias
        context.coordinator.rotationWrapper = rotationWrapper
        
        // Guardar referencia
        context.coordinator.contentView = hostingController.view
        context.coordinator.scrollView = scrollView
        context.coordinator.hostingController = hostingController
        
        // Configurar gestos
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapGesture)
        context.coordinator.doubleTapGesture = doubleTapGesture
        
        // Gestos de rotación con dos dedos
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
        scrollView.addGestureRecognizer(rotationGesture)
        context.coordinator.rotationGesture = rotationGesture
        
        // Configurar el delegate para permitir gestos simultáneos
        rotationGesture.delegate = context.coordinator
        context.coordinator.setupGestureDelegates()
        
        // Ajustar inicialmente después de que el layout se establezca
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Forzar layout primero
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
            
            // Ajustar después
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                context.coordinator.fitContent()
            }
        }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Si cambia el resetTrigger, resetear el zoom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            context.coordinator.fitContent()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(config: config)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var config: ZoomConfig
        var scrollView: UIScrollView?
        var hostingController: UIHostingController<MapContent>?
        var contentView: UIView?
        var rotationWrapper: UIView?
        var doubleTapGesture: UITapGestureRecognizer?
        var rotationGesture: UIRotationGestureRecognizer?
        var currentRotation: CGFloat = 0
        var lastRotation: CGFloat = 0
        
        init(config: ZoomConfig) {
            self.config = config
        }
        
        func setupGestureDelegates() {
            rotationGesture?.delegate = self
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Permitir que rotation y pinch funcionen simultáneamente
            if (gestureRecognizer == rotationGesture && otherGestureRecognizer is UIPinchGestureRecognizer) ||
               (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer == rotationGesture) {
                return true
            }
            return false
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            // El ScrollView hace zoom en el wrapper, no en el contenido directamente
            return rotationWrapper
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Aplicar rotación al wrapper después del zoom
            if currentRotation != 0, let rotationWrapper = rotationWrapper {
                let rotationTransform = CGAffineTransform(rotationAngle: currentRotation)
                rotationWrapper.transform = rotationTransform
            }
            centerContentIfNeeded(in: scrollView)
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = scrollView else { return }
            
            let location = gesture.location(in: scrollView)
            let currentScale = scrollView.zoomScale
            let newScale: CGFloat
            
            if currentScale < config.doubleTapScale {
                newScale = config.doubleTapScale
            } else {
                newScale = scrollView.minimumZoomScale
            }
            
            let zoomRect = calculateZoomRect(for: location, scale: newScale, in: scrollView)
            scrollView.zoom(to: zoomRect, animated: true)
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let rotationWrapper = rotationWrapper,
                  gesture.numberOfTouches == 2 else { return }
            
            switch gesture.state {
            case .began:
                lastRotation = currentRotation
            case .changed:
                // Acumular la rotación
                currentRotation = lastRotation + gesture.rotation
                
                // Aplicar rotación al wrapper (que contiene el contenido)
                // El ScrollView maneja el zoom del wrapper, nosotros aplicamos la rotación
                let rotationTransform = CGAffineTransform(rotationAngle: currentRotation)
                rotationWrapper.transform = rotationTransform
                
            case .ended, .cancelled:
                // Mantener la rotación final
                lastRotation = currentRotation
                break
            default:
                break
            }
        }
        
        func fitContent() {
            guard let scrollView = scrollView,
                  let rotationWrapper = rotationWrapper else { return }
            
            // Resetear rotación al ajustar
            currentRotation = 0
            rotationWrapper.transform = .identity
            
            rotationWrapper.setNeedsLayout()
            rotationWrapper.layoutIfNeeded()
            
            DispatchQueue.main.async {
                // Esperar un frame más para que el layout se establezca completamente
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let scrollViewSize = scrollView.bounds.size
                    
                    // Obtener el tamaño del wrapper
                    let wrapperSize = rotationWrapper.frame.size
                    
                    // Si no tiene tamaño válido, usar el tamaño mínimo
                    var finalContentSize = wrapperSize
                    if finalContentSize.width < 100 || finalContentSize.height < 100 {
                        finalContentSize = CGSize(width: 1000, height: 800)
                    }
                    
                    // Asegurar que el contenido tenga al menos el tamaño mínimo
                    finalContentSize.width = max(finalContentSize.width, 1000)
                    finalContentSize.height = max(finalContentSize.height, 800)
                    
                    // Actualizar el contentSize del scrollView
                    // Usar el tamaño del contenido más un margen para permitir rotación
                    let margin: CGFloat = 200 // Margen extra para rotación
                    let diagonalSize = sqrt(finalContentSize.width * finalContentSize.width + finalContentSize.height * finalContentSize.height)
                    scrollView.contentSize = CGSize(
                        width: diagonalSize + margin,
                        height: diagonalSize + margin
                    )
                    
                    // Calcular el scale para encajar completamente el mapa
                    let widthScale = scrollViewSize.width / finalContentSize.width
                    let heightScale = scrollViewSize.height / finalContentSize.height
                    let fittingScale = min(widthScale, heightScale) * 0.95 // 95% para dejar margen
                    
                    // Asegurar que el scale esté dentro de los límites
                    let minScale = max(self.config.minScale, min(fittingScale, 1.0))
                    
                    // Aplicar el zoom
                    scrollView.minimumZoomScale = minScale
                    scrollView.zoomScale = minScale
                    
                    // Centrar el contenido
                    self.centerContentIfNeeded(in: scrollView)
                }
            }
        }
        
        private func centerContentIfNeeded(in scrollView: UIScrollView) {
            guard let rotationWrapper = rotationWrapper else { return }
            
            let boundsSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let wrapperFrame = rotationWrapper.frame
            
            // Calcular el offset para centrar el wrapper
            var offsetX: CGFloat = 0
            var offsetY: CGFloat = 0
            
            // Centrar el wrapper dentro del contentSize
            let centeredX = (contentSize.width - wrapperFrame.width) / 2
            let centeredY = (contentSize.height - wrapperFrame.height) / 2
            
            rotationWrapper.frame = CGRect(
                x: centeredX,
                y: centeredY,
                width: wrapperFrame.width,
                height: wrapperFrame.height
            )
            
            // Ajustar el contentOffset para centrar en la vista
            if contentSize.width < boundsSize.width {
                offsetX = (boundsSize.width - contentSize.width) / 2
            }
            
            if contentSize.height < boundsSize.height {
                offsetY = (boundsSize.height - contentSize.height) / 2
            }
            
            scrollView.contentOffset = CGPoint(x: -offsetX, y: -offsetY)
        }
        
        private func calculateZoomRect(for point: CGPoint, scale: CGFloat, in scrollView: UIScrollView) -> CGRect {
            let scrollViewSize = scrollView.bounds.size
            let newWidth = scrollViewSize.width / scale
            let newHeight = scrollViewSize.height / scale
            
            let x = point.x - (newWidth / 2)
            let y = point.y - (newHeight / 2)
            
            return CGRect(x: x, y: y, width: newWidth, height: newHeight)
        }
    }
}

// MARK: - Map Content
struct MapContent: View {
    var body: some View {
        Group {
            if UIImage(named: "azteca_plan") != nil {
                Image("azteca_plan")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 1000, minHeight: 800)
            } else {
                // Placeholder del mapa con tamaño fijo grande
                VStack(spacing: 20) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accessibleLime.opacity(0.5))
                    
                    Text("Mapa del Estadio Azteca")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.routeText)
                    
                    Text("Planta del estadio")
                        .font(.subheadline)
                        .foregroundColor(.routeMuted)
                    
                    // Cuadrícula simulada del mapa más grande
                    VStack(spacing: 2) {
                        ForEach(0..<15) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<15) { col in
                                    Rectangle()
                                        .fill((row + col) % 2 == 0 ? 
                                              Color.accessibleLime.opacity(0.1) : 
                                              Color.accessibleLime.opacity(0.05))
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Text("Usa gestos para navegar • Toca el botón para ver completo")
                        .font(.caption)
                        .foregroundColor(.routeMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                .frame(width: 1000, height: 800)
                .background(Color.routePanelGreen.opacity(0.5))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    ZoomPanScrollViewWrapper(
        config: .init(minScale: 0.3, maxScale: 4.0, doubleTapScale: 1.8, extraPanInset: 180)
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.routeDarkGreen)
}

