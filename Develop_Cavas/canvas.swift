//
//  canvas.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/23/24.
//
import SwiftUI
import SwiftUI

import PencilKit

struct DrawingView: UIViewRepresentable {
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView

        init(parent: DrawingView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Handle drawing changes if needed
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update UIView if needed
    }
}

#Preview {
    DrawingView()
        .edgesIgnoringSafeArea(.all)

}
