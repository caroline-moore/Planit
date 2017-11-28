//
//  AvailabilityInterval.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct Availability: Codable
{
    var user: User!
    var interval: DateInterval = DateInterval()
}
