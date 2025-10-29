import SwiftUI
import UIKit

/// Carga una imagen desde Assets o del bundle (png/jpg).
/// Si no existe, muestra un placeholder simple.
struct AssetImage: View {
    let name: String
    let contentMode: ContentMode

    init(_ name: String, contentMode: ContentMode = .fit) {
        self.name = name
        self.contentMode = contentMode
    }

    var body: some View {
        // Siempre devolvemos el MISMO tipo de vista (Image -> View),
        // sin ViewBuilder ni ramas con tipos distintos.
        image()
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }

    private func image() -> Image {
        // 1) Intentar en Assets
        if let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        }

        // 2) Intentar archivo suelto en el bundle (png/jpg)
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: name, ofType: ext),
               let ui = UIImage(contentsOfFile: path) {
                return Image(uiImage: ui)
            }
        }

        // 3) Fallback: ícono de sistema como placeholder
        return Image(systemName: "photo")
    }
}
