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
    static let temporary = User(name: "Me", email: "me@me.com", id: 1064)
    
    static let caroline = User(name: "Caroline", email: "carolimm@usc.edu", id: 103)
    static let tyler = User(name: "Tyler", email: "tacklee@usc.edu", id: 109)
    static let alex = User(name: "Alex", email: "alex@usc.edu", id: 201)
    static let gordon = User(name: "Gordon", email: "gordon@usc.edu", id: 270)
    
    var identifier: Int = 0
    var name: String = ""
    var email: String = ""
    
    var createdEvents: [Event]! = []
    var joinedEvents: [Event]! = []
    var invitedEvents: [Event]! = []
    
    init(name: String, email: String, id: Int)
    {
        self.name = name
        self.email = email
        self.identifier = id
    }
    
    private enum CodingKeys: String, CodingKey
    {
        case identifier
        case name
        case email
    }
}

extension User: Hashable
{
    var hashValue: Int {
        return self.name.hashValue
    }
    
    static func ==(lhs: User, rhs: User) -> Bool
    {
        return lhs.name == rhs.name
    }
}
