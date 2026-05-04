import ApplicationServices
import ArgumentParser
import Foundation

struct Resolve: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Resolve a node_id to an AX element and perform an action."
    )

    @Option(name: .long, help: "Process PID.")
    var pid: Int32

    @Option(name: .long, help: "Node ID (axg:...).")
    var nodeId: String

    @Flag(name: .long, help: "Perform AXPress action after resolving.")
    var press: Bool = false

    func run() throws {
        guard let app = AppEnumerator.find(pid: pid) else {
            FileHandle.standardError.write(Data("no app found for pid \(pid)\n".utf8))
            throw ExitCode.failure
        }

        let opts = WalkOptions(includeDOM: true, maxDepth: 64)
        let walker = AXTreeWalker(bundleID: app.bundleID, opts: opts)

        for win in AppEnumerator.windows(of: app) {
            _ = walker.walk(win)
        }

        guard let element = walker.pointers[nodeId] else {
            FileHandle.standardError.write(Data("node_id \(nodeId) not found in snapshot\n".utf8))
            throw ExitCode.failure
        }

        if press {
            let result = AXUIElementPerformAction(element, kAXPressAction as CFString)
            if result == .success {
                print("{\"status\":\"ok\",\"action\":\"AXPress\",\"node_id\":\"\(nodeId)\"}")
            } else {
                FileHandle.standardError.write(Data("AXPress failed: \(result)\n".utf8))
                throw ExitCode.failure
            }
        } else {
            print("{\"status\":\"ok\",\"action\":\"resolved\",\"node_id\":\"\(nodeId)\"}")
        }
    }
}
