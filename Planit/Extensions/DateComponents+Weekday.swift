//
//  DateComponents+Weekday.swift
//  Planit
//
//  Created by Caroline Moore on 11/26/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

extension Calendar
{
    enum Weekday: Int
    {
        case sunday = 1
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        
        static var allValues: [Weekday] {
            return [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        }
        
        var localizedName: String {
            switch self
            {
            case .sunday: return NSLocalizedString("Sunday", comment: "")
            case .monday: return NSLocalizedString("Monday", comment: "")
            case .tuesday: return NSLocalizedString("Tuesday", comment: "")
            case .wednesday: return NSLocalizedString("Wednesday", comment: "")
            case .thursday: return NSLocalizedString("Thursday", comment: "")
            case .friday: return NSLocalizedString("Friday", comment: "")
            case .saturday: return NSLocalizedString("Saturday", comment: "")
            }
        }
        
        var localizedAbbreviation: String {
            switch self
            {
            case .sunday: return NSLocalizedString("S", comment: "")
            case .monday: return NSLocalizedString("M", comment: "")
            case .tuesday: return NSLocalizedString("T", comment: "")
            case .wednesday: return NSLocalizedString("W", comment: "")
            case .thursday: return NSLocalizedString("Th", comment: "")
            case .friday: return NSLocalizedString("F", comment: "")
            case .saturday: return NSLocalizedString("Sa", comment: "")
            }
        }
    }
}

extension DateComponents
{
    var gregorianWeekday: Calendar.Weekday? {
        get {
            guard let day = self.weekday else { return nil }
            
            let weekday = Calendar.Weekday(rawValue: day)
            return weekday
        }
        set {
            self.weekday = newValue?.rawValue
        }
    }
}
