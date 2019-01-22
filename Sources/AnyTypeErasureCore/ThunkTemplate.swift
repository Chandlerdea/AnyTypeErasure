//
//  ThunkTemplate.swift
//  AnyTypeErasure
//
//  Created by Chandler De Angelis on 1/21/19.
//

import Foundation

struct ThunkTemplateFactory {
    
    static func makeTemplate(with definition: ProtocolDefinition, path: String) -> Template {
        let name: String = "Any\(definition.name)"
        var contents: String = "struct \(name)<\(definition.associatedTypeName!)>: \(definition.name) {\n\n"
        for (name, type) in definition.mutableProperties {
            contents += "    private var _\(name): \(type)\n"
        }
        for (name, type) in definition.computedProperties {
            contents += "    private let _\(name): \(type)\n"
        }
        for (name, args) in definition.functionArguments {
            var funcProperty: String = "    private let _\(name): ("
            funcProperty += args.compactMap({ $0.key }).joined(separator: ", ")
            funcProperty += ")"
            if let returnType: String = definition.functionReturnTypes[name] {
                funcProperty += " -> \(returnType)\n"
            } else {
                funcProperty += " -> ()\n"
            }
            contents += funcProperty
        }
        
        contents += "\n    init<T: \(definition.name)>(_ \(definition.name.lowercased()): T) where T.\(definition.associatedTypeName!) == \(definition.associatedTypeName!) {\n"
        for (varName, _) in definition.mutableProperties {
            contents += "        self._\(varName) = \(definition.name.lowercased()).\(varName)\n"
        }
        for (varName, _) in definition.computedProperties {
            contents += "        self._\(varName) = \(definition.name.lowercased()).\(varName)\n"
        }
        for (funcName, _) in definition.functionArguments {
            contents += "        self._\(funcName) = \(definition.name.lowercased()).\(funcName)\n"
        }
        contents += "    }\n"
        
        for (varName, type) in definition.computedProperties {
            contents += """
            
                var \(varName): \(type) {
                    return self._\(varName)
                }
            
            """
        }
        
        for (varName, type) in definition.mutableProperties {
            contents += """
            
                var \(varName): \(type) {
                    get {
                        return self._\(varName)
                    }
                    set {
                        self._\(varName) = newValue
                    }
                }
            
            """
        }
        
        for (funcName, args) in definition.functionArguments {
            let argsString: String = args.compactMap({ "\($0.value.joined(separator: " ")): \($0.key)" }).joined(separator: ",")
            var signature: String = "\n    func \(funcName)(\(argsString))"
            if let returnType: String = definition.functionReturnTypes[funcName] {
                signature += " -> \(returnType) {\n"
            } else {
                signature += " -> Void {\n"
            }
            contents += signature
            if let _ = definition.functionReturnTypes[funcName] {
                contents += "        return self._\(funcName)(\(args.compactMap({ $0.value.last }).joined(separator: ",")))"
            } else {
                contents += "        self._\(funcName)(\(args.compactMap({ $0.value.last }).joined(separator: ",")))"
            }
            contents += "\n    }\n"
        }
        
        contents.append("\n}\n")
        let comps: [String] = Array(path.components(separatedBy: "/").dropLast())
        let directoryPath: String = comps.joined(separator: "/")
        let location: URL = URL(fileURLWithPath: "\(directoryPath)/\(name).swift")
        print("\n\(contents)\n")
        let result: Template = Template(location: location, contents: contents)
        return result
    }
    
}


