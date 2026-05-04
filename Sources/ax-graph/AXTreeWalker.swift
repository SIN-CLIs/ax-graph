import ApplicationServices
import Foundation

struct WalkOptions {
    var includeDOM: Bool = true
    var maxDepth: Int = 64
    var includeInvisible: Bool = false
}

final class AXTreeWalker {
    let bundleID: String
    let opts: WalkOptions
    private(set) var pointers: [String: AXUIElement] = [:]

    init(bundleID: String, opts: WalkOptions = WalkOptions()) {
        self.bundleID = bundleID
        self.opts = opts
    }

    func walk(_ element: AXUIElement, parent: String? = nil,
              path: String = "", depth: Int = 0) -> AXNode? {
        if depth > opts.maxDepth { return nil }

        let role = AXAttr.string(element, kAXRoleAttribute as String) ?? "AXUnknown"
        let subrole = AXAttr.string(element, kAXSubroleAttribute as String)
        let title = AXAttr.string(element, kAXTitleAttribute as String)
        let value = AXAttr.string(element, kAXValueAttribute as String)
        let label = AXAttr.string(element, kAXDescriptionAttribute as String)
        let help = AXAttr.string(element, kAXHelpAttribute as String)
        let identifier = AXAttr.string(element, kAXIdentifierAttribute as String)
        let enabled = AXAttr.bool(element, kAXEnabledAttribute as String)
        let focused = AXAttr.bool(element, kAXFocusedAttribute as String)

        let domId = opts.includeDOM ? AXAttr.string(element, AXChromeAttr.domIdentifier) : nil
        let domClasses = opts.includeDOM ? AXAttr.stringArray(element, AXChromeAttr.domClassList) : nil
        let url = AXAttr.string(element, AXChromeAttr.url)

        let pos = AXAttr.point(element, kAXPositionAttribute as String)
        let size = AXAttr.size(element, kAXSizeAttribute as String)
        var frame: [Double]?
        if let p = pos, let s = size {
            frame = [Double(p.x), Double(p.y), Double(s.width), Double(s.height)]
        }

        let actions = AXAttr.actionNames(element)
        let segmentKey = identifier ?? domId ?? title ?? role
        let newPath = path.isEmpty ? role : "\(path)/\(role)[\(abs(segmentKey.hashValue) % 1000)]"
        let nodeId = NodeID.make(
            bundle: bundleID,
            path: newPath,
            role: role,
            domId: domId,
            identifier: identifier,
            title: title
        )

        pointers[nodeId] = element
        let kidPtrs = AXAttr.children(element)
        var kids: [AXNode] = []
        kids.reserveCapacity(kidPtrs.count)
        for kp in kidPtrs {
            if let n = walk(kp, parent: nodeId, path: newPath, depth: depth + 1) {
                kids.append(n)
            }
        }

        return AXNode(
            nodeId: nodeId,
            role: role,
            subrole: subrole,
            title: title,
            value: value,
            label: label,
            help: help,
            identifier: identifier,
            domId: domId,
            domClasses: domClasses,
            url: url,
            frame: frame,
            enabled: enabled,
            focused: focused,
            actions: actions,
            path: newPath,
            parent: parent,
            children: kids
        )
    }
}
