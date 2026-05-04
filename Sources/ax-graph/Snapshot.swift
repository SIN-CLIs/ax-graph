import ApplicationServices
import ArgumentParser
import Crypto
import Foundation

struct Snapshot: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Take a one-shot AX snapshot of one or all running apps."
    )

    @Flag(name: .long, help: "Include all running apps (default if no --pid/--bundle).")
    var all: Bool = false

    @Option(name: .long, help: "Restrict to a single process by PID.")
    var pid: Int32?

    @Option(name: .long, help: "Restrict to apps matching a bundle identifier.")
    var bundle: String?

    @Flag(name: .long, inversion: .prefixedNo,
          help: "Include AXDOMIdentifier/AXDOMClassList (Chrome/WebKit DOM bridge).")
    var includeDom: Bool = true

    @Option(name: .long, help: "Max recursion depth.")
    var maxDepth: Int = 64

    @Flag(name: .long, help: "Pretty-print JSON instead of compact JSONL.")
    var pretty: Bool = false

    func run() throws {
        let opts = WalkOptions(includeDOM: includeDom, maxDepth: maxDepth)
        var apps: [AppInfo] = AppEnumerator.runningApps()
        if let p = pid {
            apps = apps.filter { $0.pid == p }
        } else if let b = bundle {
            apps = apps.filter { $0.bundleID == b }
        }
        if apps.isEmpty {
            FileHandle.standardError.write(Data(
                "no matching apps found (check Privacy & Security > Accessibility)\n".utf8
            ))
            throw ExitCode.failure
        }
        let snapshot = buildSnapshot(apps: apps, opts: opts)
        emit(snapshot)
    }

    private func buildSnapshot(apps: [AppInfo], opts: WalkOptions) -> SnapshotPayload {
        var payloadApps: [SnapshotApp] = []
        payloadApps.reserveCapacity(apps.count)
        for app in apps {
            let walker = AXTreeWalker(bundleID: app.bundleID, opts: opts)
            var winNodes: [SnapshotWindow] = []
            for win in AppEnumerator.windows(of: app) {
                let title = AXAttr.string(win, kAXTitleAttribute as String) ?? ""
                let isMain = AXAttr.bool(win, kAXMainAttribute as String) ?? false
                let pos = AXAttr.point(win, kAXPositionAttribute as String) ?? .zero
                let sz = AXAttr.size(win, kAXSizeAttribute as String) ?? .zero
                guard let root = walker.walk(win) else { continue }
                winNodes.append(SnapshotWindow(
                    title: title,
                    frame: [Double(pos.x), Double(pos.y), Double(sz.width), Double(sz.height)],
                    isMain: isMain,
                    root: root
                ))
            }
            payloadApps.append(SnapshotApp(
                pid: Int(app.pid),
                bundleId: app.bundleID,
                name: app.name,
                isActive: app.isActive,
                windows: winNodes
            ))
        }
        let stamp = Date().timeIntervalSince1970
        let idSeed = payloadApps.map(\.bundleId).joined(separator: ",") + "@\(stamp)"
        let digest = SHA256.hash(data: Data(idSeed.utf8))
        let snapId = "snap:" + digest.prefix(8).map { String(format: "%02x", $0) }.joined()
        return SnapshotPayload(snapshotId: snapId, timestamp: stamp, apps: payloadApps)
    }

    private func emit(_ s: SnapshotPayload) {
        let enc = JSONEncoder()
        enc.outputFormatting = pretty
            ? [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            : [.withoutEscapingSlashes]
        do {
            let data = try enc.encode(s)
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write(Data("\n".utf8))
        } catch {
            FileHandle.standardError.write(Data("encode error: \(error)\n".utf8))
        }
    }
}

struct SnapshotPayload: Codable {
    let snapshotId: String
    let timestamp: Double
    let apps: [SnapshotApp]
}

struct SnapshotApp: Codable {
    let pid: Int
    let bundleId: String
    let name: String
    let isActive: Bool
    let windows: [SnapshotWindow]
}

struct SnapshotWindow: Codable {
    let title: String
    let frame: [Double]
    let isMain: Bool
    let root: AXNode
}
