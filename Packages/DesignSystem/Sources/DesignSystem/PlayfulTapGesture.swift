import Foundation
import SwiftUI

public extension View {
    func playfulTapGesture(onTap: @escaping () -> Void) -> some View {
        PlayfulTapGestureView(content: self, onTap: onTap)
    }
}

private struct PlayfulTapGestureView<Content: View>: View {
    @GestureState private var isTapped: Bool = false
    let content: Content
    let onTap: () -> Void
    
    var body: some View {
        content.gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in onTap() }
                .updating($isTapped) { _, isTapped, _ in
                    isTapped = true
                }
        )
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.15), value: isTapped)
    }
    
    private var scale: CGSize {
        if isTapped {
            return CGSize(width: 0.95, height: 0.95)
        } else {
            return CGSize(width: 1, height: 1)
        }
    }
}
