//
//  TimesViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/13/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class TimesViewController: UICollectionViewController
{
    var availabilityIntervals = [DateInterval]()
    
    var weekday: DateComponents.Weekday! {
        didSet {
            guard let collectionView = self.collectionView else { return }
            
            let collectionViewLayout = self.collectionViewLayout as! CalendarViewLayout
            collectionViewLayout.visibleWeekday = self.weekday
            
            collectionView.reloadData()
        }
    }
    
    var user: User?
    
    private var updatingIndexPath: IndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let calendar = Calendar(identifier: .gregorian)
        
        let startDate = calendar.date(from: DateComponents(hour: 8))!
        let endDate = calendar.date(from: DateComponents(hour: 24))!

        let collectionViewLayout = self.collectionViewLayout as! CalendarViewLayout
        collectionViewLayout.dataSource = self
        collectionViewLayout.visibleDateInterval = DateInterval(start: startDate, end: endDate)
        collectionViewLayout.visibleWeekday = self.weekday
        
        self.collectionView?.register(CalendarViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TimesViewController.addAvailibilityInterval(with:)))
        self.collectionView?.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = PanGestureRecognizer(target: self, action: #selector(TimesViewController.handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        self.collectionView?.addGestureRecognizer(panGestureRecognizer)
        
        self.collectionView?.panGestureRecognizer.cancelsTouchesInView = false
        self.collectionView?.panGestureRecognizer.require(toFail: panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension TimesViewController
{
    @objc func addAvailibilityInterval(with gestureRecognizer: UITapGestureRecognizer)
    {
        guard let collectionView = self.collectionView, let collectionViewLayout = self.collectionViewLayout as? CalendarViewLayout else { return }
        
        guard collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) == nil else { return }
        
        let calendar = Calendar(identifier: .gregorian)
        
        let intervalStartHour = calendar.component(.hour, from: collectionViewLayout.visibleDateInterval.start)
        let hourOffset = Int((gestureRecognizer.location(in: collectionView).y - collectionViewLayout.rowHeight / 2.0) / collectionViewLayout.rowHeight)
        
        let date = DateComponents(calendar: calendar, hour: intervalStartHour + hourOffset, weekday: self.weekday.rawValue, weekdayOrdinal: 1).date!
        
        let interval = DateInterval(start: date, duration: 1 * 60 * 60)
        self.availabilityIntervals.append(interval)
        
        collectionView.reloadData()
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        guard let collectionView = self.collectionView, let collectionViewLayout = self.collectionViewLayout as? CalendarViewLayout, let gestureRecognizer = gestureRecognizer as? PanGestureRecognizer else { return }
        
        let location = gestureRecognizer.location(in: collectionView)
        
        switch gestureRecognizer.state
        {
        case .began:
            let initialLocation = gestureRecognizer.initialTouchLocation(in: collectionView)
            self.updatingIndexPath = collectionView.indexPathForItem(at: initialLocation)
            
        case .changed:
            guard location.y >= 0 && location.y <= collectionView.bounds.maxY else { return }
            
            guard let indexPath = self.updatingIndexPath else { return }
            
            guard let frame = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }
            
            let translation = gestureRecognizer.translation(in: collectionView).y
            
            let hourOffset = translation / collectionViewLayout.rowHeight
            
            var interval = self.availabilityIntervals[indexPath.item]
            
            let timeIntervalOffset = TimeInterval(hourOffset * 60 * 60)
            
            if abs(location.y - frame.midY) < abs(location.y - frame.maxY)
            {
                if interval.duration > 1 * 60 * 60 || timeIntervalOffset < 0
                {
                    interval = DateInterval(start: interval.start.addingTimeInterval(timeIntervalOffset), end: interval.end)
                }
            }
            else
            {
                if interval.duration > 1 * 60 * 60 || timeIntervalOffset > 0
                {
                    interval = DateInterval(start: interval.start, duration: interval.duration + timeIntervalOffset)
                }
            }
            
            self.availabilityIntervals[indexPath.item] = interval
            
        default:
            // Round interval to nearest hour
            guard let indexPath = self.updatingIndexPath else { return }
            
            var interval = self.availabilityIntervals[indexPath.item]
            
            let calendar = Calendar(identifier: .gregorian)
            
            var startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal], from: interval.start)
            var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal], from: interval.end)
            
            if startComponents.minute! >= 30
            {
                startComponents.hour = startComponents.hour! + 1
            }
            startComponents.minute = 0
            
            if endComponents.minute! >= 30
            {
                endComponents.hour = endComponents.hour! + 1
            }
            endComponents.minute = 0
            
            interval.start = calendar.date(from: startComponents)!
            interval.end = calendar.date(from: endComponents)!
            
            self.availabilityIntervals[indexPath.item] = interval
            
            self.updatingIndexPath = nil
        }
        
        collectionViewLayout.invalidateLayout()
        
        gestureRecognizer.setTranslation(.zero, in: collectionView)
    }
}

extension TimesViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        guard let collectionView = self.collectionView, let gestureRecognizer = gestureRecognizer as? PanGestureRecognizer else { return false }
        
        let location = gestureRecognizer.initialTouchLocation(in: collectionView)
        
        guard let indexPath = self.collectionView?.indexPathForItem(at: location) else { return false }
        
        guard let frame = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return false }
        
        let threshold: CGFloat = 22.0
        
        let shouldBegin = abs(frame.minY - location.y) < threshold || abs(frame.maxY - location.y) < threshold
        return shouldBegin
    }
}

extension TimesViewController
{
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.availabilityIntervals.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarViewCell
        cell.tintColor = UIColor.planitBlue
        cell.textLabel.text = self.user?.name ?? "Event"
        return cell
    }
}

extension TimesViewController: CalendarViewLayoutDataSource
{
    func calendarViewLayout(_ calendarViewLayout: CalendarViewLayout, dateIntervalForItemAt indexPath: IndexPath) -> DateInterval
    {
        let interval = self.availabilityIntervals[indexPath.row]
        return interval
    }
}
