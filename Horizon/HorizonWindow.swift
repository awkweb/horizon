// By Tom Meagher on 1/20/21 at 22:15

import Foundation
import SwiftUI

class HorizonWindow: NSPanel {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        level = .popUpMenu
        hidesOnDeactivate = false
        center()
        isMovableByWindowBackground = true
        isExcludedFromWindowsMenu = false
        isFloatingPanel = true
        styleMask.insert(.nonactivatingPanel)
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        let rootView = RootView()
        contentView = NSHostingView(rootView: rootView)
        backgroundColor = .clear
    }

    override var canBecomeKey: Bool {
        get { return true }
    }

    override var canBecomeMain: Bool {
        get { return true }
    }
}
