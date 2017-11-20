//
//  CalendarViewLayout.swift
//  Planit
//
//  Created by Caroline Moore on 11/13/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension DateComponents
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
    
    var gregorianWeekday: Weekday? {
        get {
            guard let day = self.weekday else { return nil }
            
            let weekday = Weekday(rawValue: day)
            return weekday
        }
        set {
            self.weekday = newValue?.rawValue
        }
    }
}

class CalendarViewTimeLayoutAttributes: UICollectionViewLayoutAttributes
{
    var text = ""
    var timeColumnWidth: CGFloat = 44.0
}

protocol CalendarViewLayoutDataSource: class
{
    func calendarViewLayout(_ calendarViewLayout: CalendarViewLayout, dateIntervalForItemAt indexPath: IndexPath) -> DateInterval
}

class CalendarViewLayout: UICollectionViewLayout
{
    weak var dataSource: CalendarViewLayoutDataSource?
    
    var visibleDateInterval: DateInterval!
    var visibleWeekday: DateComponents.Weekday = .sunday
    
    var timeColumnWidth: CGFloat = 44
    
    var rowHeight: CGFloat = 44
    
    private var rowCount: Int {
        return (Int(self.visibleDateInterval.duration) / (1 * 60 * 60)) + 1
    }
    
    private var contentWidth: CGFloat {
        return self.collectionViewContentSize.width - self.timeColumnWidth
    }
    
    private var itemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var timeAttributes = [IndexPath: CalendarViewTimeLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        guard var size = self.collectionView?.bounds.size else { return super.collectionViewContentSize}
        
        size.height = self.rowHeight * CGFloat(self.rowCount)
        return size
    }
    
    override func prepare()
    {
        guard let collectionView = self.collectionView, let collectionViewDataSource = self.collectionView?.dataSource, let dataSource = self.dataSource else { return }
        
        self.register(CalendarTimeDecorationView.self, forDecorationViewOfKind: CalendarTimeDecorationView.decorationViewKind)
        
        let calendar = Calendar(identifier: .gregorian)
        
        guard let intervalStartHour = calendar.dateComponents([.hour], from: self.visibleDateInterval.start).hour else { return }
        
        var itemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
        var timeAttributes = [IndexPath: CalendarViewTimeLayoutAttributes]()
        
        // Items
        for i in 0 ..< collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        {
            let indexPath = IndexPath(row: i, section: 0)
            
            let interval = dataSource.calendarViewLayout(self, dateIntervalForItemAt: indexPath)
            
            let startDateComponents = calendar.dateComponents([.hour, .minute, .weekday], from: interval.start)
            
            guard
                let weekday = startDateComponents.gregorianWeekday,
                weekday == self.visibleWeekday
            else { continue }
            
            guard
                let startHour = startDateComponents.hour,
                let startMinutes = startDateComponents.minute
            else { continue }
            
            var frame = self.baseFrame(forItemAt: indexPath)
            
            frame.origin.y += self.rowHeight / 2.0
            frame.origin.y += self.rowHeight * CGFloat(startHour - intervalStartHour)
            frame.origin.y += self.rowHeight * (CGFloat(startMinutes) / 60.0)
            
            frame.size.height = self.rowHeight * CGFloat(interval.duration / 60.0 / 60.0)
                        
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame.integral
            
            itemAttributes[indexPath] = attributes
        }
        
        // Times
        for i in 0 ..< self.rowCount
        {
            let indexPath = IndexPath(item: i, section: 0)
            
            var frame = CGRect(x: 0, y: 0, width: self.collectionViewContentSize.width, height: self.rowHeight)
            frame.origin.y = (frame.height / 2.0) + frame.height * CGFloat(indexPath.item)
            
            let attributes = CalendarViewTimeLayoutAttributes(forDecorationViewOfKind: CalendarTimeDecorationView.decorationViewKind, with: indexPath)
            attributes.zIndex = -10
            attributes.frame = frame.integral
            attributes.timeColumnWidth = self.timeColumnWidth
            
            let hour = indexPath.item + intervalStartHour
            
            let suffix = (hour >= 12 && hour < 24) ? "PM" : "AM"
            
            let localizedHour = "\((hour > 12) ? hour - 12 : hour) \(suffix)"
            attributes.text = localizedHour
            
            timeAttributes[indexPath] = attributes
        }
        
        self.itemAttributes = itemAttributes
        self.timeAttributes = timeAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        func predicate(_ attributes: UICollectionViewLayoutAttributes) -> Bool
        {
            return attributes.frame.intersects(rect)
        }
        
        let attributes: [UICollectionViewLayoutAttributes] = self.itemAttributes.values.filter(predicate) + self.timeAttributes.values.filter(predicate)
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = self.itemAttributes[indexPath]
        return attributes
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = self.timeAttributes[indexPath]
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        guard let bounds = self.collectionView?.bounds else { return false }
        
        let shouldInvalidate = bounds.width != newBounds.width
        return shouldInvalidate
    }
}

private extension CalendarViewLayout
{
    func baseFrame(forItemAt itemIndexPath: IndexPath) -> CGRect
    {
        guard let collectionView = self.collectionView, let collectionViewDataSource = self.collectionView?.dataSource, let dataSource = self.dataSource else { return .zero }
        
        let itemInterval = dataSource.calendarViewLayout(self, dateIntervalForItemAt: itemIndexPath)
        
        var count: CGFloat = 0
        var index: CGFloat = 0
        
        var beforeIndexPath = true
        
        for i in 0 ..< collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        {
            let indexPath = IndexPath(row: i, section: 0)
            
            if indexPath == itemIndexPath
            {
                beforeIndexPath = false
            }
            
            let interval = dataSource.calendarViewLayout(self, dateIntervalForItemAt: indexPath)
            
            // Intervals may intersect with duration of 0 (such as when only one end overlaps), so ensure intersection is > 0
            if let intersection = interval.intersection(with: itemInterval), intersection.duration > 0
            {
                count += 1
                
                if beforeIndexPath
                {
                    index += 1
                }
            }
        }
        
        let width = self.contentWidth / count
        
        let frame = CGRect(x: self.timeColumnWidth + (index * width), y: 0, width: width, height: 0)
        return frame
    }
}
