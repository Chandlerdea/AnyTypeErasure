import Foundation
import AnyTypeErasureCore

do {
    let typeErasure: AnyTypeErasure = try AnyTypeErasure()
    try typeErasure.run()
} catch {
    switch error {
    case Arguments.Error.noArguments:
        print("""
        👋 AnyTypeErasure is a tool that creates type erasure value types for your protocols with associated types.
           The only argument required is the path to the protocol, and the new file will be written in the current directory.
        """)
    case ProtocolParser.Error.noAssociatedType:
        print("🧐 The protocol has no assicated type, why are you trying to use type erasure????")
    case ProtocolParser.Error.noProtocolDefinition:
        print("👮‍♀️ No protocol definition found in file at \(CommandLine.arguments[1])")
    case ProtocolParser.Error.fileNotFound:
        print("👮‍♀️ File not found at \(CommandLine.arguments[1])")
    default:
        print("💥 An unknown error occurred")
    }
    exit(1)
}
