import ApplicationServices
import Crypto
import Foundation

struct AXNode: Codable {
    let nodeId: String
    let role: String
    let subrole: String?
    let title: String?
    let value: String?
    let label: String?
    let help: String?
    let identifier: String?
    let domId: String?
    let domClasses: [String]?
    let url: String?
    let frame: [Double]?
    let enabled: Bool?
    let focused: Bool?
    let actions: [String]
    let path: String
    let parent: String?
    let children: [AXNode]
}

enum NodeID {
    static func make(bundle: String, path: String, role: String,
                     domId: String?, identifier: String?, title: String?) -> String {
        let parts = [
            bundle,
            path,
            role,
            domId ?? "",
            identifier ?? "",
            (domId == nil && identifier == nil) ? (title ?? "") : ""
        ]
        let joined = parts.joined(separator: "|")
        let digest = SHA256.hash(data: Data(joined.utf8))
        let hex = digest.compactMap { String(format: "%02x", $0) }.joined()
        return "axg:" + String(hex.prefix(16))
    }
}
