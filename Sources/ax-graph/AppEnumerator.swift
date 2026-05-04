import AppKit
import ApplicationServices
import Foundation

struct AppInfo {
    let pid: pid_t
    let bundleID: String
    let name: String
    let isActive: Bool
    let axElement: AXUIElement
}

enum AppEnumerator {
    static func runningApps() -> [AppInfo] {
        let apps = NSWorkspace.shared.runningApplications
        var result: [AppInfo] = []
        for app in apps {
            if app.activationPolicy == .prohibited { continue }
            guard let bundle = app.bundleIdentifier else { continue }
            let pid = app.processIdentifier
            if pid <= 0 { continue }
            let axApp = AXUIElementCreateApplication(pid)
            var raw: CFTypeRef?
            let st = AXUIElementCopyAttributeValue(axApp, kAXRoleAttribute as CFString, &raw)
            if st != .success { continue }
            result.append(AppInfo(
                pid: pid,
                bundleID: bundle,
                name: app.localizedName ?? bundle,
                isActive: app.isActive,
                axElement: axApp
            ))
        }
        return result
    }

    static func find(pid: pid_t) -> AppInfo? {
        runningApps().first { $0.pid == pid }
    }

    static func find(bundleID: String) -> [AppInfo] {
        runningApps().filter { $0.bundleID == bundleID }
    }

    static func windows(of app: AppInfo) -> [AXUIElement] {
        var raw: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app.axElement,
                                            kAXWindowsAttribute as CFString,
                                            &raw) == .success,
              let arr = raw as? [AXUIElement] else { return [] }
        return arr
    }
}
