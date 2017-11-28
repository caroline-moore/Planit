//
//  User.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct User: Codable
{
    static var current: User?
    
    var identifier: Int = 0
    var name: String = ""
    var email: String = ""
    
    var createdEvents: [Event] = []
    var joinedEvents: [Event] = []
    var invitedEvents: [Event] = []
    
    init(name: String, email: String, id: Int)
    {
        self.name = name
        self.email = email
        self.identifier = id
    }
}

extension User: Hashable
{
    var hashValue: Int
    {
        return self.identifier.hashValue
    }
    
    static func ==(lhs: User, rhs: User) -> Bool
    {
        return lhs.identifier == rhs.identifier
    }
}
