//
//  Availability.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct Availability
{
    var user: User
    var interval: DateInterval
}

extension Availability: CustomStringConvertible
{
    var description: String {
        let description = "Availability: \(self.user.name), \(self.interval.weekday.localizedName), \(self.interval.startHourLocalized) - \(self.interval.endHourLocalized)"
        return description
    }
}

extension Availability: Comparable
{
    static func ==(lhs: Availability, rhs: Availability) -> Bool
    {
        return lhs.user == rhs.user && lhs.interval == rhs.interval
    }
    
    static func <(lhs: Availability, rhs: Availability) -> Bool
    {
        if lhs.interval.weekday != rhs.interval.weekday
        {
            return lhs.interval.weekday.rawValue < rhs.interval.weekday.rawValue
        }
        
        if lhs.interval.start != rhs.interval.start
        {
            return lhs.interval.start < rhs.interval.start
        }
        
        if lhs.interval.end != rhs.interval.end
        {
            return lhs.interval.end < rhs.interval.end
        }
        
        return lhs.user.name < rhs.user.name
    }
}

extension Availability: Hashable
{
    var hashValue: Int {
        return self.user.hashValue ^ (self.interval as NSDateInterval).hashValue
    }
}
