import ApplicationServices
import ArgumentParser
import Foundation

struct Watch: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Watch a process for live AX mutations via AXObserver."
    )

    @Option(name: .long, help: "Process PID to watch.")
    var pid: Int32

    @Option(name: .long, help: "Max events before exit (0 = unlimited).")
    var maxEvents: Int = 0

    func run() throws {
        guard let app = AppEnumerator.find(pid: pid) else {
            FileHandle.standardError.write(Data("no app found for pid \(pid)\n".utf8))
            throw ExitCode.failure
        }
        print("watching pid \(pid) (\(app.name)) for AX mutations...", to: &FileHandle.standardError)
        // AXObserver setup requires a run loop; this is a minimal scaffold.
        // Full implementation will stream JSONL mutation events to stdout.
        let observer = AXObserverCreateWithRunLoop(pid: pid)
        observer.start()
        // Block until interrupted.
        dispatchMain()
    }
}

/// Minimal AXObserver wrapper.
private final class AXPollingObserver {
    private let pid: pid_t
    private var observer: AXObserver?
    private var running = false

    init(pid: pid_t) {
        self.pid = pid
    }

    func start() {
        guard !running else { return }
        running = true
        let app = AXUIElementCreateApplication(pid)
        var obs: AXObserver?
        let status = AXObserverCreate(pid, { _, element, notification, refcon in
            guard let refcon = refcon else { return }
            let `self` = Unmanaged<AXPollingObserver>.fromOpaque(refcon).takeUnretainedValue()
            let notifName = notification as String? ?? "unknown"
            var title: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title)
            let info: [String: Any] = [
                "notification": notifName,
                "title": (title as? String) ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
            if let data = try? JSONSerialization.data(withJSONObject: info) {
                FileHandle.standardOutput.write(data)
                FileHandle.standardOutput.write(Data("\n".utf8))
            }
        }, &obs)
        guard status == .success, let obs = obs else {
            FileHandle.standardError.write(Data("AXObserverCreate failed: \(status)\n".utf8))
            return
        }
        self.observer = obs
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        AXObserverAddNotification(obs, app, kAXFocusedWindowChangedNotification as CFString, selfPtr)
        AXObserverAddNotification(obs, app, kAXFocusedUIElementChangedNotification as CFString, selfPtr)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(obs), .commonModes)
    }
}

private func AXObserverCreateWithRunLoop(pid: pid_t) -> AXPollingObserver {
    return AXPollingObserver(pid: pid)
}
