//
//  ProtocolDefinition.swift
//  AnyTypeErasure
//
//  Created by Chandler De Angelis on 1/20/19.
//

import Foundation

struct ProtocolDefinition {
    
    let name: String
    
    var isClassProtocol: Bool = false
    
    var associatedTypeName: String! = .none
    
    /**
     The key being the name of the variable, and the value being the type
    */
    var computedProperties: [String: String] = [:]
    
    /**
     The key being the name of the variable, and the value being the type
    */
    var mutableProperties: [String: String] = [:]
    
    /**
     The key being the name of the functions, and the value being a dictionary of arguments, where the key being the type, and the value being the argument labels
    */
    var functionArguments: [String: [String: [String]]] = [:]
    
    /**
     The key being the name of the functions, and the value being the return value of the function
    */
    var functionReturnTypes: [String: String] = [:]
    
    init(name: String) {
        self.name = name
    }
    
}
