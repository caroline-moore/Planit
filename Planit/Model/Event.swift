//
//  Event.swift
//  Planit
//
//  Created by Caroline Moore. All rights reserved.
//

import Foundation

struct Event: Codable
{
    var identifier: Int = 0
    var name: String = ""
    var duration: TimeInterval = 0
    var isRecurring: Bool = false
    var isPublic: Bool = false
    var URL: String = ""
    
    var creator: User!
    
    var availabilityIntervals = [DateInterval]()
    //var availabilities = Set<Availability>()
    
    var invitedEmails = Set<String>()
    
    var joinedUsers = Set<User>()
}
