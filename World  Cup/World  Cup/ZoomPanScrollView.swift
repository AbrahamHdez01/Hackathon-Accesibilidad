import SwiftUI
import UIKit

// MARK: - Zoom Configuration
struct ZoomConfig {
    var minScale: CGFloat = 0.5
    var maxScale: CGFloat = 3.0
    var doubleTapScale: CGFloat = 1.8
    var extraPanInset: CGFloat = 160 // aire para moverse fuera del mapa
}

// MARK: - Zoom Pan Scroll View
struct ZoomPanScrollView<Content: View>: UIViewRepresentable {
    var config: ZoomConfig
    @ViewBuilder var content: () -> Content
    
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
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        context.coordinator.hostingController = hostingController
        
        // Agregar la vista del hosting controller al scroll view
        scrollView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Guardar referencia para actualizar constraints
        context.coordinator.contentView = hostingController.view
        context.coordinator.scrollView = scrollView
        
        // Configurar gestos
        setupGestures(for: scrollView, context: context)
        
        // Ajustar inicialmente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            context.coordinator.fitContent()
        }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Actualizar constraints si es necesario
        if let contentView = context.coordinator.contentView,
           let hostingController = context.coordinator.hostingController {
            // Actualizar el contenido
            hostingController.rootView = content()
            
            // Re-ajustar después de actualizar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                context.coordinator.fitContent()
            }
        }
    }
    
    private func setupGestures(for scrollView: UIScrollView, context: Context) {
        // Doble tap para zoom
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        context.coordinator.doubleTapGesture = doubleTapGesture
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(config: config)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var config: ZoomConfig
        var scrollView: UIScrollView?
        var hostingController: UIHostingController<Content>?
        var contentView: UIView?
        var doubleTapGesture: UITapGestureRecognizer?
        
        init(config: ZoomConfig) {
            self.config = config
        }
        
        // MARK: - UIScrollViewDelegate
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return contentView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContentIfNeeded(in: scrollView)
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            // Asegurar que el zoom esté dentro de los límites
            scrollView.zoomScale = max(config.minScale, min(config.maxScale, scale))
        }
        
        // MARK: - Gesture Handlers
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = scrollView else { return }
            
            let location = gesture.location(in: scrollView)
            let currentScale = scrollView.zoomScale
            let newScale: CGFloat
            
            if currentScale < config.doubleTapScale {
                // Acercar
                newScale = config.doubleTapScale
            } else {
                // Alejar a fit
                newScale = config.minScale
            }
            
            // Calcular el punto de zoom
            let zoomRect = calculateZoomRect(
                for: location,
                scale: newScale,
                in: scrollView
            )
            
            scrollView.zoom(to: zoomRect, animated: true)
        }
        
        // MARK: - Helper Methods
        
        func fitContent() {
            guard let scrollView = scrollView,
                  let contentView = contentView else { return }
            
            // Calcular el tamaño del contenido
            let contentSize = contentView.sizeThatFits(scrollView.bounds.size)
            let scrollViewSize = scrollView.bounds.size
            
            // Calcular el scale para encajar
            let widthScale = scrollViewSize.width / contentSize.width
            let heightScale = scrollViewSize.height / contentSize.height
            let minScale = min(widthScale, heightScale) * 0.9 // 90% para dejar un poco de espacio
            
            // Aplicar el zoom
            scrollView.minimumZoomScale = min(config.minScale, minScale)
            scrollView.zoomScale = minScale
            
            // Centrar contenido
            centerContentIfNeeded(in: scrollView)
        }
        
        private func centerContentIfNeeded(in scrollView: UIScrollView) {
            guard let contentView = contentView else { return }
            
            let boundsSize = scrollView.bounds.size
            var frameToCenter = contentView.frame
            
            // Centrar horizontalmente
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // Centrar verticalmente
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            contentView.frame = frameToCenter
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

// MARK: - Preview
#Preview {
    ZoomPanScrollView(config: .init(minScale: 0.6, maxScale: 3.5, doubleTapScale: 1.8, extraPanInset: 180)) {
        Image(systemName: "map.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 800, height: 600)
            .background(Color.gray.opacity(0.2))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.routeDarkGreen)
}

