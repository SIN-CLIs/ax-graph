import ApplicationServices
import Foundation

enum AXChromeAttr {
    static let domIdentifier  = "AXDOMIdentifier"
    static let domClassList   = "AXDOMClassList"
    static let url            = "AXURL"
}

enum AXAttr {
    static func string(_ el: AXUIElement, _ name: String) -> String? {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &raw) == .success,
              let v = raw else { return nil }
        if CFGetTypeID(v) == CFStringGetTypeID() {
            return v as? String
        }
        if CFGetTypeID(v) == CFURLGetTypeID() {
            return (v as! CFURL).absoluteString
        }
        return nil
    }

    static func stringArray(_ el: AXUIElement, _ name: String) -> [String]? {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &raw) == .success,
              let arr = raw as? [Any] else { return nil }
        return arr.compactMap { $0 as? String }
    }

    static func bool(_ el: AXUIElement, _ name: String) -> Bool? {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &raw) == .success,
              let v = raw else { return nil }
        if CFGetTypeID(v) == CFBooleanGetTypeID() {
            return CFBooleanGetValue((v as! CFBoolean))
        }
        return nil
    }

    static func point(_ el: AXUIElement, _ name: String) -> CGPoint? {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &raw) == .success,
              let v = raw else { return nil }
        var p = CGPoint.zero
        if AXValueGetValue((v as! AXValue), .cgPoint, &p) { return p }
        return nil
    }

    static func size(_ el: AXUIElement, _ name: String) -> CGSize? {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &raw) == .success,
              let v = raw else { return nil }
        var s = CGSize.zero
        if AXValueGetValue((v as! AXValue), .cgSize, &s) { return s }
        return nil
    }

    static func children(_ el: AXUIElement) -> [AXUIElement] {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, kAXChildrenAttribute as CFString, &raw) == .success,
              let arr = raw as? [AXUIElement] else { return [] }
        return arr
    }

    static func actionNames(_ el: AXUIElement) -> [String] {
        var raw: CFArray?
        guard AXUIElementCopyActionNames(el, &raw) == .success,
              let names = raw as? [String] else { return [] }
        return names
    }

    static func attributeNames(_ el: AXUIElement) -> [String] {
        var raw: CFArray?
        guard AXUIElementCopyAttributeNames(el, &raw) == .success,
              let names = raw as? [String] else { return [] }
        return names
    }
}
