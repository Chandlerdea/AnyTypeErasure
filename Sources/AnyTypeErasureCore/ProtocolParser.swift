//
//  ProtocolParser.swift
//  AnyTypeErasure
//
//  Created by Chandler De Angelis on 1/20/19.
//

import Foundation

typealias StringRange = Range<String.Index>

public struct ProtocolParser {
    
    public enum Error: Swift.Error {
        case noProtocolDefinition
        case noAssociatedType
        case fileNotFound
    }
    
    private let lines: [String]
    private let path: String
    
    init(path: String) throws {
        guard let file: String = try? String(contentsOfFile: path) else {
            throw Error.fileNotFound
        }
        self.lines = file.components(separatedBy: .newlines)
        self.path = path
    }
    
    func parse() throws -> Template {
        let result: Template
        var definition: ProtocolDefinition? = .none
        for line in self.lines {
            let strippedLine: String = line.components(separatedBy: .whitespaces).joined(separator: "")
            if let protocolKeywordRange: StringRange = strippedLine.range(of: "protocol"), let openBraceRange: StringRange = strippedLine.range(of: "{") {
                let protocolNameRange: StringRange
                if let classColonRange: StringRange = strippedLine.range(of: ":class") {
                    protocolNameRange = protocolKeywordRange.upperBound..<classColonRange.lowerBound
                    definition?.isClassProtocol = true
                } else {
                    protocolNameRange = protocolKeywordRange.upperBound..<openBraceRange.lowerBound
                }
                definition = ProtocolDefinition(name: String(strippedLine[protocolNameRange]))
            } else if let variableKeywordRange: StringRange = strippedLine.range(of: "var"), let typeColonRange: StringRange = strippedLine.range(of: ":"), let openBraceRange: StringRange = strippedLine.range(of: "{") {
                let variableNameRange: StringRange = variableKeywordRange.upperBound..<typeColonRange.lowerBound
                let typeRange: StringRange = strippedLine.index(after: typeColonRange.lowerBound)..<openBraceRange.lowerBound
                let variableName: String = String(strippedLine[variableNameRange])
                let typeName: String = String(strippedLine[typeRange])
                let getSetString: String = String(strippedLine[openBraceRange.upperBound..<strippedLine.endIndex])
                guard let _ = getSetString.range(of: "get") else {
                    print("😥 variable \(variableName) must have at least a getter")
                    continue
                }
                if let _ = getSetString.range(of: "set") {
                    definition?.mutableProperties[variableName] = typeName
                } else {
                    definition?.computedProperties[variableName] = typeName
                }
            } else if let associatedTypeKeywordRange: StringRange = strippedLine.range(of: "associatedtype") {
                let typeNameRange: StringRange = associatedTypeKeywordRange.upperBound..<strippedLine.endIndex
                definition?.associatedTypeName = String(strippedLine[typeNameRange])
            } else if let funcKeywordRange: StringRange = line.range(of: "func"), let openParenthesisRange: StringRange = line.range(of: "("), let closeParenthesisRange: StringRange = line.range(of: ")") {
                let name: String = String(line[line.index(after: funcKeywordRange.upperBound)..<openParenthesisRange.lowerBound])
                let argumentsString: String = String(line[openParenthesisRange.upperBound..<closeParenthesisRange.lowerBound])
                let argumentStrings: [String] = argumentsString.components(separatedBy: ",")
                var arguments: [String: [String]] = [:]
                for argument in argumentStrings {
                    let comps: [String] = argument.components(separatedBy: ":")
                    let argumentLabels: [String] = comps[0].components(separatedBy: " ")
                    let type: String = comps[1].components(separatedBy: " ").last! // account for space between the colon and type
                    arguments[type] = argumentLabels
                }
                definition?.functionArguments[name] = arguments
                if let returnIndicatorRange: StringRange = strippedLine.range(of: "->") {
                    let returnTypeRange: StringRange = returnIndicatorRange.upperBound..<strippedLine.endIndex
                    let returnTypeString: String = String(strippedLine[returnTypeRange])
                    definition?.functionReturnTypes[name] = returnTypeString
                }
            }
        }
        guard let _ = definition?.associatedTypeName else {
            throw Error.noAssociatedType
        }
        guard let unwrappedDefinition: ProtocolDefinition = definition else {
            throw Error.noProtocolDefinition
        }
        result = ThunkTemplateFactory.makeTemplate(with: unwrappedDefinition, path: self.path)
        return result
    }
}
