import Foundation

public final class AnyTypeErasure {
    
    private let arguments: Arguments
    
    public init() throws {
        self.arguments = try Arguments()
    }
    
    public func run() throws {
        let parser: ProtocolParser = try ProtocolParser(path: self.arguments.protocolPath)
        let template: Template = try parser.parse()
        try template.write()
    }
}
