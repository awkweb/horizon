// By Tom Meagher on 1/20/21 at 22:15

import Foundation
import SwiftUI

class HorizonWindow: NSPanel {
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                   styleMask: [],
                   backing: .buffered,
                   defer: false)
        level = .popUpMenu
        hasShadow = true
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

        let store = AppStore()
        let rootView = RootView(window: self).environmentObject(store)
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
