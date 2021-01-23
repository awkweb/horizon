// By Tom Meagher on 1/23/21 at 12:34

import SwiftUI

final class StatusBarMenuItem: NSMenuItem {
    private let callback: (NSMenuItem) -> Void

    init(
        _ title: String,
        key: String = "",
        callback: @escaping (NSMenuItem) -> Void
    ) {
        self.callback = callback
        super.init(title: title, action: #selector(action(_:)), keyEquivalent: key)
        self.target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("Not yet implemented.")
    }

    @objc
    func action(_ sender: NSMenuItem) {
        callback(sender)
    }
}
