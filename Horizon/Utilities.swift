// By Tom Meagher on 1/26/21 at 20:25

import SwiftUI

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension NSApplication {
    func quit() {
        NSApp.terminate(nil)
    }
}

/**
Makes it easier to get mime type
*/
func getMimeTypeFor(fileUrl url: URL) -> String? {
    guard
        let extUTI = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            url.pathExtension as CFString,
            nil)?.takeUnretainedValue()
    else { return nil }
    
    guard
        let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
     else { return nil }
    
    return mimeUTI.takeRetainedValue() as String
}

/**
Convenience function for initializing an object and modifying its properties.
```
let label = with(NSTextField()) {
    $0.stringValue = "Foo"
    $0.textColor = .systemBlue
    view.addSubview($0)
}
```
*/
@discardableResult
func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var this = item
    try update(&this)
    return this
}

func getFileForUrl(url fileUrl: URL) -> File? {
    // Get file data
    guard let data = try? Data(contentsOf: fileUrl) else { return nil }

    // Get mime type
    guard let mimeType = getMimeTypeFor(fileUrl: fileUrl) else { return nil }

    return File(name: fileUrl.lastPathComponent, data: data, mimeType: mimeType)
}
