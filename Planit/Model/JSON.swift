//
//  JSON.swift
//  Planit
//
//  Created by Caroline on 11/27/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation

struct JSON: Codable
{
    var type: String = ""
    var user: User? = nil
    var event: Event? = nil
}
