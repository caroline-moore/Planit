//
//  Event.swift
//  Planit
//
//  Created by Caroline Moore. All rights reserved.
//

import Foundation

struct Event
{
    var name: String = ""
    var duration: TimeInterval = 0
    var isRecurring: Bool = false
    var isPublic: Bool = false
    var URL: String = ""
    
    var identifier: Int = 0
    
    var creator: User!
    
    var availabilityIntervals = Set<NSDateInterval>()
    var availabilities = Set<Availability>()
    
    var invitedEmails = Set<String>()
    
    var joinedUsers = Set<User>()
    
    init()
    {
    }
    
    init(name: String, creator: User, isPublic: Bool, invitedEmails: Set<String>, joinedUsers: Set<User>)
    {
        self.name = name
        self.creator = creator
        self.isPublic = isPublic
        self.invitedEmails = invitedEmails
        self.joinedUsers = joinedUsers
    }
}

extension Event: Hashable
{
    var hashValue: Int {
        return self.name.hashValue
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool
    {
        return lhs.name == rhs.name
    }
}
