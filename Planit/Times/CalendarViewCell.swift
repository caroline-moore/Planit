//
//  CalendarViewCell.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class CalendarViewCell: UICollectionViewCell
{
    let textLabel: UILabel
    
    override init(frame: CGRect)
    {
        self.textLabel = UILabel()
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel.textColor = .white
        
        super.init(frame: frame)
        
        self.contentView.addSubview(self.textLabel)
        
        let backgroundView = UIView()
        backgroundView.alpha = 0.7
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        self.backgroundView = backgroundView
        
        NSLayoutConstraint.activate([
            self.textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            self.textLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -5)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange()
    {
        super.tintColorDidChange()
        
        self.backgroundView?.backgroundColor = self.tintColor
    }
}
