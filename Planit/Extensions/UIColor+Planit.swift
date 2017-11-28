//
//  UIColor+Planit.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension UIColor
{
    static let planitRed = UIColor(named: "PlanitRed", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitPink = UIColor(named: "PlanitPink", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitOrange = UIColor(named: "PlanitOrange", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitYellow = UIColor(named: "PlanitYellow", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitGreen = UIColor(named: "PlanitGreen", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitBlue = UIColor(named: "PlanitBlue", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let planitPurple = UIColor(named: "PlanitPurple", in: Bundle(for: LaunchViewController.self), compatibleWith: nil)!
    
    static let contentColors: [UIColor] = {
        return [.planitRed, .planitPink, .planitOrange, .planitYellow, .planitGreen, .planitBlue]
    }()
}
