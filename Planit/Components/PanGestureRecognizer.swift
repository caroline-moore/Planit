//
//  PanGestureRecognizer.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class PanGestureRecognizer: UIPanGestureRecognizer
{
    var initialTouchLocation: CGPoint = .zero
    
    func initialTouchLocation(in view: UIView?) -> CGPoint
    {
        let point = self.view?.convert(self.initialTouchLocation, to: view) ?? .zero
        return point
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesBegan(touches, with: event)
        
        self.initialTouchLocation = touches.first!.location(in: self.view)
    }
}
