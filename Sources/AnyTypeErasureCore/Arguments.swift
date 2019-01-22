//
//  Arguments.swift
//  AnyTypeErasure
//
//  Created by Chandler De Angelis on 1/20/19.
//

import Foundation

public struct Arguments {
    
    public enum Error: Swift.Error {
        case noArguments
    }
    
    let protocolPath: String
    
    init(commandLineArguments: [String] = CommandLine.arguments) throws {
        guard commandLineArguments.count == 2 else {
            throw Error.noArguments
        }
        self.protocolPath = commandLineArguments[1]
    }
}
