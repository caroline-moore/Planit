//
//  DateInterval+Hours.swift
//  Planit
//
//  Created by Caroline Moore on 11/26/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

extension DateInterval
{
    var startHour: Int {
        let hour = Calendar.current.component(.hour, from: self.start)
        return hour
    }
    
    var startHourLocalized: String {
        let hour = self.startHour
        
        let localized = hour > 12 ? "\(hour - 12)PM" : "\(hour)AM"
        return localized
    }
    
    var endHour: Int {
        let hour = Calendar.current.component(.hour, from: self.end)
        return hour
    }
    
    var endHourLocalized: String {
        let hour = self.endHour
        
        let localized = hour > 12 ? "\(hour - 12)PM" : "\(hour)AM"
        return localized
    }
    
    var weekday: Calendar.Weekday {
        let day = Calendar.current.component(.weekday, from: self.start)
        
        let weekday = Calendar.Weekday(rawValue: day)!
        return weekday
    }
}
