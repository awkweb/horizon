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
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 300),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        center()
        isMovableByWindowBackground = true
        hasShadow = true
        setFrameAutosaveName("main")
        
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        hidesOnDeactivate = false
        isExcludedFromWindowsMenu = false
        
        isFloatingPanel = true
        level = .floating
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        let rootView = PublishView(
            viewModel: PublishViewModel(
                store: store,
                onClose: onClose
            ),
            parent: self
        )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .environmentObject(store)
        
        contentView = NSHostingView(rootView: rootView)        
        resize()
    }
    
    func resize() {
        setContentSize(contentView!.fittingSize)
    }
}
