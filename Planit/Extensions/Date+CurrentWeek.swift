//
//  Date+CurrentWeek.swift
//  Planit
//
//  Created by Caroline Moore on 11/26/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

extension Date
{
    var currentWeekStart: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        return date.addingTimeInterval(dslTimeOffset)
    }
    
    var currentWeekEnd: Date {
        return Calendar.current.date(byAdding: .second, value: 604799, to: self.currentWeekStart)!
    }
}
