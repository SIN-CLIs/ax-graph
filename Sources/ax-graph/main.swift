import ArgumentParser
import Foundation

struct AXGraph: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ax-graph",
        abstract: "Unified accessibility tree indexer for macOS (apps + Chrome web content).",
        subcommands: [Snapshot.self, Watch.self, Resolve.self],
        defaultSubcommand: Snapshot.self
    )
}

AXGraph.main()
