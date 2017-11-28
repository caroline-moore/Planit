//
//  EventsTableViewCell.swift
//  Planit
//
//  Created by Caroline Moore on 11/27/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell
{
    @IBOutlet var roundedBackgroundView: UIView!
    
    @IBOutlet var invitedUsersCountLabel: UILabel!
    @IBOutlet var joinedUsersCountLabel: UILabel!
    
    @IBOutlet var creatorLabel: UILabel!
    
    @IBOutlet var joinedUsersStackView: UIStackView!
    @IBOutlet var isPrivateImageView: UIImageView!
    
    @IBOutlet var eventNameLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        
        self.roundedBackgroundView.layer.cornerRadius = 10
        
        self.roundedBackgroundView.clipsToBounds = false
        self.roundedBackgroundView.layer.shadowColor = UIColor.black.cgColor
        self.roundedBackgroundView.layer.shadowRadius = 16.0
        self.roundedBackgroundView.layer.shadowOffset = CGSize(width: 0.0, height: 16.0)
        self.roundedBackgroundView.layer.shadowOpacity = 0.15
    }
}
