//
//  CalendarTimeDecorationView.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation
import UIKit

class CalendarTimeDecorationView: UICollectionReusableView
{
    static let decorationViewKind = "TimeDecorationView"
    
    let textLabel: UILabel
    
    var timeColumnWidth: CGFloat = 44.0
    
    private let horizontalLineView: UIView
    
    override init(frame: CGRect)
    {
        self.textLabel = UILabel()
        self.textLabel.textColor = .gray
        self.textLabel.font = UIFont.systemFont(ofSize: 10)
        
        self.horizontalLineView = UIView()
        self.horizontalLineView.backgroundColor = .lightGray
        
        super.init(frame: frame)
        
        self.addSubview(self.textLabel)
        self.addSubview(self.horizontalLineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let padding: CGFloat = 2.0
        let horizontalLineExtension: CGFloat = 4.0
        let onePixelWidth = 1.0 / UIScreen.main.scale
        
        let size = self.textLabel.sizeThatFits(CGSize(width: self.bounds.width - self.timeColumnWidth - padding * 2.0, height: self.bounds.height))
        
        self.textLabel.frame = CGRect(x: self.timeColumnWidth - padding - horizontalLineExtension - size.width, y: 0 - size.height / 2.0, width: size.width, height: size.height).integral
        
        self.horizontalLineView.frame = CGRect(x: self.timeColumnWidth - horizontalLineExtension, y: 0, width: self.bounds.width - self.timeColumnWidth + horizontalLineExtension, height: onePixelWidth)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes)
    {
        super.apply(layoutAttributes)
        
        guard let layoutAttributes = layoutAttributes as? CalendarViewTimeLayoutAttributes else { return }
        
        self.timeColumnWidth = layoutAttributes.timeColumnWidth
        self.textLabel.text = layoutAttributes.text
        
        self.setNeedsLayout()
    }
}
