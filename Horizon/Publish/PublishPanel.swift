// By Tom Meagher on 1/23/21 at 12:14

import Foundation
import SwiftUI

class PublishPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    init(
        store: Store,
        onClose: @escaping () -> Void
    ) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        backgroundColor = .clear
        center()
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        hasShadow = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        isExcludedFromWindowsMenu = false
        isFloatingPanel = true
        level = .popUpMenu

        let rootView = PublishView(
            viewModel: PublishViewModel(
                store: store,
                onClose: onClose
            )
        ).environmentObject(store)
        contentView = NSHostingView(rootView: rootView)
    }
}

