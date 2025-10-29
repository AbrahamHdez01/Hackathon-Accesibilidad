import SwiftUI
import UIKit

#if canImport(Lottie)
import Lottie
#else
/// Fallback stub for LottieLoopMode when Lottie isn't integrated.
enum LottieLoopMode {
    case loop
    case playOnce
}
#endif

/// Muestra animación Lottie si está disponible (`.json` o `.lottie`), si no, imagen (Assets / PNG/JPG en bundle).
struct AssetVisual: View {
    let name: String
    var preferLottie: Bool = true            // si hay Lottie, la usa
    var imageContentMode: ContentMode = .fit

    // Keep these properties available regardless of Lottie presence so callers don't need to change.
    var lottieLoop: LottieLoopMode = .loop
    var lottieSpeed: CGFloat = 1.0

    var body: some View {
        Group {
            #if canImport(Lottie)
            if preferLottie, hasLottie(name) {
                LottieRepresentable(name: name, loopMode: lottieLoop, speed: lottieSpeed)
            } else if let img = loadUIImage(name) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: imageContentMode)
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.25))
                        )
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                        Text("Asset not found: \(name)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 6)
                    }.padding(8)
                }
            }
            #else
            if let img = loadUIImage(name) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: imageContentMode)
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.25))
                        )
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                        Text("Asset not found: \(name)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 6)
                    }.padding(8)
                }
            }
            #endif
        }
    }

    // MARK: - Helpers
    private func hasLottie(_ name: String) -> Bool {
        if Bundle.main.path(forResource: name, ofType: "json") != nil { return true }
        if Bundle.main.path(forResource: name, ofType: "lottie") != nil { return true }
        return false
    }

    private func loadUIImage(_ name: String) -> UIImage? {
        if let ui = UIImage(named: name) { return ui } // Assets
        for ext in ["png", "jpg", "jpeg"] {
            if let p = Bundle.main.path(forResource: name, ofType: ext),
               let ui = UIImage(contentsOfFile: p) { return ui }
        }
        return nil
    }
}

#if canImport(Lottie)
private struct LottieRepresentable: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed
        if !uiView.isAnimationPlaying { uiView.play() }
    }
}
#endif
