//
//  JSON.swift
//  Planit
//
//  Created by Caroline on 11/27/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct UserJSON: Codable
{
    var type: String!
    var user: User? = nil
}

struct UserIdJSON: Codable
{
    var type: String!
    var userID: Int?
}

struct EventJSON: Codable
{
    var type: String!
    var event: Event? = nil
    var user: User?
}

struct EventIdJSON: Codable
{
    var type: String!
    var eventID: Int?
}

struct EventListJSON: Codable
{
    var type: String!
    var events: Array<Event>?
}

struct AvailabilityListJSON: Codable
{
    var type: String!
    var availabilities: Array<Availability>?
}
