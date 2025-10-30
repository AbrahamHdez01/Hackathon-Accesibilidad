import SwiftUI

#if canImport(Lottie)
import Lottie

public struct AnimatedAssetView: UIViewRepresentable {
    public let name: String
    public var loopMode: LottieLoopMode = .loop
    public var speed: CGFloat = 1.0
    public var contentMode: UIView.ContentMode = .scaleAspectFill
    public var allowOverflow: Bool = false

    public init(name: String,
                loopMode: LottieLoopMode = .loop,
                speed: CGFloat = 1.0,
                contentMode: UIView.ContentMode = .scaleAspectFill,
                allowOverflow: Bool = false) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
        self.contentMode = contentMode
        self.allowOverflow = allowOverflow
    }

    public func makeUIView(context: Context) -> UIView {
        // Contenedor fijo que sigue el frame de SwiftUI
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = !allowOverflow

        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = contentMode
        animationView.clipsToBounds = !allowOverflow
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed

        if let animation = LottieAnimation.named(name, bundle: .main) {
            animationView.animation = animation
            animationView.play()
        } else {
            #if DEBUG
            print("⚠️ Lottie JSON no encontrado: \(name)")
            #endif
        }

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Guardar referencia para updateUIView
        container.tag = 4242
        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // Buscar el LottieAnimationView hijo
        guard let animationView = uiView.subviews.first(where: { $0 is LottieAnimationView }) as? LottieAnimationView else { return }
        animationView.contentMode = contentMode
        animationView.clipsToBounds = !allowOverflow
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        if animationView.animation == nil, let animation = LottieAnimation.named(name, bundle: .main) {
            animationView.animation = animation
        }
        if !animationView.isAnimationPlaying { animationView.play() }
    }
}
#else
public struct AnimatedAssetView: View {
    public let name: String
    public init(name: String, loopMode: Any = (), speed: CGFloat = 1.0) { self.name = name }
    public var body: some View { EmptyView() }
}
#endif
