import UIKit
import SwiftUI

class ViewCaptureManager {
    static let shared = ViewCaptureManager()
    private var views: [String: UIView] = [:]
    
    func setView(_ view: UIView, for id: String) {
        views[id] = view
    }

    func captureView(with id: String) -> UIImage? {
        guard let view = views[id] else { return nil }
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

struct CaptureView: UIViewRepresentable {
    let id: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            ViewCaptureManager.shared.setView(view, for: id)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
