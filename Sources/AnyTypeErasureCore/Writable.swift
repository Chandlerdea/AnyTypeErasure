//
//  Writable.swift
//  AnyTypeErasure
//
//  Created by Chandler De Angelis on 1/20/19.
//

import Foundation

protocol Writable {
    func write() throws
}

extension Writable where Self == Template {
    
    func write() throws {
        try self.contents.write(
            to: self.location,
            atomically: true,
            encoding: .utf8
        )
    }
}
