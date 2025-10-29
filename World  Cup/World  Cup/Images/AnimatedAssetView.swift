import SwiftUI

#if canImport(Lottie)
import Lottie

public struct AnimatedAssetView: UIViewRepresentable {
    public let name: String
    public var loopMode: LottieLoopMode = .loop
    public var speed: CGFloat = 1.0

    public init(name: String, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }

    public func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = speed

        // Lottie v4: cargar animación por nombre desde el bundle principal
        if let animation = LottieAnimation.named(name, bundle: .main) {
            view.animation = animation
            view.play()
        } else {
            #if DEBUG
            print("⚠️ Lottie JSON no encontrado: \(name)")
            #endif
        }
        return view
    }

    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed
        if uiView.animation == nil {
            if let animation = LottieAnimation.named(name, bundle: .main) {
                uiView.animation = animation
            }
        }
        if !uiView.isAnimationPlaying { uiView.play() }
    }
}
#else
public struct AnimatedAssetView: View {
    public let name: String
    public init(name: String, loopMode: Any = (), speed: CGFloat = 1.0) { self.name = name }
    public var body: some View { EmptyView() }
}
#endif
