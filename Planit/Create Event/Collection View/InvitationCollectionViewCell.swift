//
//  InvitationCollectionViewCell.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class InvitationCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var textLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}
