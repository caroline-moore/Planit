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
    var availabilities = [Availability]()
    
    var weekday: Calendar.Weekday! {
        didSet {
            guard let collectionView = self.collectionView else { return }
            
            let collectionViewLayout = self.collectionViewLayout as! CalendarViewLayout
            collectionViewLayout.visibleWeekday = self.weekday
            
            collectionView.reloadData()
        }
    }
    
    var colors: [UIColor] = UIColor.contentColors
    
    private var user: User {
        return User.current ?? User.temporary
    }
    
    private var updatingIndexPath: IndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let calendar = Calendar(identifier: .gregorian)
        
        let startDate = calendar.date(from: DateComponents(hour: 8))!
        let endDate = calendar.date(from: DateComponents(hour: 23))!

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
        
        let location = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = self.collectionView?.indexPathForItem(at: location)
        {
            let availability = self.availabilities[indexPath.item]
            
            guard availability.user != self.user else { return }
        }
        
        let user = self.user
        
        let calendar = Calendar(identifier: .gregorian)
        
        let intervalStartHour = calendar.component(.hour, from: collectionViewLayout.visibleDateInterval.start)
        let hourOffset = Int((location.y - collectionViewLayout.rowHeight / 2.0) / collectionViewLayout.rowHeight)
        
        let date = DateComponents(calendar: calendar, hour: intervalStartHour + hourOffset, weekday: self.weekday.rawValue, weekdayOrdinal: 1).date!
        
        let interval = DateInterval(start: date, duration: 1 * 60 * 60)
        
        let availability = Availability(user: user, interval: interval)
        self.availabilities.append(availability)
        
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
            
            if let existingIndexPath = collectionView.indexPathForItem(at: location), existingIndexPath != indexPath
            {
                return
            }
            
            let translation = gestureRecognizer.translation(in: collectionView).y
            
            let hourOffset = translation / collectionViewLayout.rowHeight
            
            var availability = self.availabilities[indexPath.item]
            
            let timeIntervalOffset = TimeInterval(hourOffset * 60 * 60)
            
            if abs(location.y - frame.midY) < abs(location.y - frame.maxY)
            {
                if availability.interval.duration > 1 * 60 * 60 || timeIntervalOffset < 0
                {
                    availability.interval = DateInterval(start: availability.interval.start.addingTimeInterval(timeIntervalOffset), end: availability.interval.end)
                }
            }
            else
            {
                if availability.interval.duration > 1 * 60 * 60 || timeIntervalOffset > 0
                {
                    availability.interval = DateInterval(start: availability.interval.start, duration: availability.interval.duration + timeIntervalOffset)
                }
            }
            
            self.availabilities[indexPath.item] = availability
            
        default:
            // Round interval to nearest hour
            guard let indexPath = self.updatingIndexPath else { return }
            
            var availability = self.availabilities[indexPath.item]
            
            let calendar = Calendar(identifier: .gregorian)
            
            var startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal], from: availability.interval.start)
            var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal], from: availability.interval.end)
            
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
            
            availability.interval.start = calendar.date(from: startComponents)!
            availability.interval.end = calendar.date(from: endComponents)!
            
            self.availabilities[indexPath.item] = availability
            
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
        
        let availability = self.availabilities[indexPath.item]
        
        guard availability.user == self.user else { return false }
        
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
        return self.availabilities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let availability = self.availabilities[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarViewCell
        cell.textLabel.text = availability.user.name
        cell.tintColor = self.color(for: availability.user)
        
        return cell
    }
    
    private func color(for user: User) -> UIColor
    {
        let users = Set(self.availabilities.lazy.map { $0.user }.filter { $0 != self.user }).sorted { $0.name < $1.name }
        
        guard let index = users.index(of: user) else {
            return (user == self.user) ? .planitPurple : .darkGray
        }
        
        let updatedIndex = index % self.colors.count
        
        let color = self.colors[updatedIndex]
        return color
    }
}

extension TimesViewController: CalendarViewLayoutDataSource
{
    func calendarViewLayout(_ calendarViewLayout: CalendarViewLayout, availabilityForItemAt indexPath: IndexPath) -> Availability
    {
        let availability = self.availabilities[indexPath.row]
        return availability
    }
}
