//
//  User.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct User
{
    static var current: User? = nil
    
    static var temporary: User = User(name: "Me", identifier: 1064)
    
    var name = ""
    
    var identifier: Int = 0
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
