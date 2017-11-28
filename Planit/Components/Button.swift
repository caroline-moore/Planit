//
//  Button.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension Button
{
    @objc enum Theme: Int
    {
        case dark
        case light
    }
}

@IBDesignable
class Button: UIButton
{
    #if !TARGET_INTERFACE_BUILDER
    @IBInspectable var theme: Theme = .dark {
        didSet {
            self.update()
        }
    }
    #else
    @IBInspectable var theme: Int = Theme.dark.rawValue
    #endif
    
    private let backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.isUserInteractionEnabled = false
        return backgroundView
    }()
    
    override var isEnabled: Bool {
        didSet {
            self.update()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize()
    {
        self.backgroundView.layer.cornerRadius = 10
        self.backgroundView.clipsToBounds = true
        
        self.insertSubview(self.backgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 16.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 16.0)
        self.layer.masksToBounds = false
        
        self.update()
    }
    
    private func update()
    {
        #if TARGET_INTERFACE_BUILDER
            guard let theme = Theme(rawValue: self.theme) else { return }
        #else
            let theme = self.theme
        #endif
        
        switch theme
        {
        case .dark: self.backgroundView.backgroundColor = .planitPurple
            self.layer.shadowOpacity = 0.14
        case .light: self.backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
            self.layer.shadowOpacity = 0.30
        }
        
        self.alpha = self.state.contains(.disabled) ? 0.5 : 1.0
    }
    
    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        
        self.update()
    }
}
