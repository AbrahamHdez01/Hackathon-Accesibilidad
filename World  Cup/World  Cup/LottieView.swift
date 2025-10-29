import SwiftUI

#if canImport(Lottie)
import Lottie

public struct LottieView: UIViewRepresentable {
    public let name: String
    public var loopMode: LottieLoopMode = .loop
    public var speed: CGFloat = 1.0

    public init(name: String, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }

    public func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name, bundle: .main)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.play()
        return view
    }

    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed
        if !uiView.isAnimationPlaying { uiView.play() }
    }
}
#else
public struct LottieView: View {
    public let name: String
    public init(name: String, loopMode: Any = (), speed: CGFloat = 1.0) { self.name = name }
    public var body: some View { EmptyView() }
}
#endif
