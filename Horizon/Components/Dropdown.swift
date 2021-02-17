// By Tom Meagher on 2/15/21 at 17:36

import Foundation
import SwiftUI

struct Dropdown<T: Hashable>: NSViewRepresentable {
    @Binding
    var selectedValue: T?
    
    @Binding
    var items: [T]
    
    private var disabled: Bool
        
    private let getItemTitle: ((T) -> String)
    private let onChange: ((T) -> Void)?
        
    init(
        selectedValue: Binding<T?>,
        items: Binding<[T]>,
        disabled: Bool,
        getItemTitle: @escaping ((T) -> String),
        onChange: ((T) -> Void)? = nil
    ) {
        self._selectedValue = selectedValue
        self._items = items
        self.disabled = disabled
        self.getItemTitle = getItemTitle
        self.onChange = onChange
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: false)
        
        // Add local shortcut `⌘ j` for opening dropdown
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.keyCode == 38 && event.modifierFlags.contains(.command) {
                button.performClick(nil)
            }
            return event
        }
        
        return button
    }

    func updateNSView(_ view: NSPopUpButton, context: Context) {
        view.removeAllItems()
        
        for (index, element) in items.enumerated() {
            let menuItem = NSMenuItem(
                title: self.getItemTitle(element),
                action: #selector(Coordinator.valueChanged(_:)),
                keyEquivalent: "\(index + 1)"
            )
            menuItem.target = context.coordinator
            view.menu?.insertItem(menuItem, at: index)
        }
        
        if let selectedValue = self.selectedValue {
            let index = self.items.firstIndex(of: selectedValue) ?? 0
            view.selectItem(at: index)
        }
        
        view.isEnabled = !disabled
    }
}

extension Dropdown {
    final class Coordinator: NSObject {
        var parent: Dropdown<T>
    
        init(_ parent: Dropdown<T>) {
            self.parent = parent
        }

        @objc
        func valueChanged(_ sender: NSMenuItem) {
            guard let index = sender.menu?.index(of: sender) else { return }
            let item = self.parent.items[index]
            self.parent._selectedValue.wrappedValue = item
            self.parent.onChange?(item)
        }
    }
}
