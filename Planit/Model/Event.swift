//
//  Event.swift
//  Planit
//
//  Created by Caroline Moorene Moore. All rights reserved.
//

import Foundation
import Alamofire

class Event: NSObject, Codable
{
    var name: String = ""
    var duration: TimeInterval = 0
    var isRecurring: Bool = false
    var isPublic: Bool = false
    
    var invitedEmails = Set<String>()
}
