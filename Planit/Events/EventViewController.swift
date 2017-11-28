//
//  EventViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/19/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit
import GameKit
import EventKit

extension EventViewController
{
    enum State
    {
        case viewing
        case addingAvailabilities
        case joined
    }
}

class EventViewController: UIViewController
{
    var event: Event!
    
    private var state = State.viewing
    
    @IBOutlet private var weekdaySegmentedControl: UISegmentedControl!
    @IBOutlet private var confirmButton: UIButton!
    
    @IBOutlet private var importCalendarButton: UIBarButtonItem!
    @IBOutlet private var leaveEventButton: UIBarButtonItem!
    
    @IBOutlet private var blurView: UIVisualEffectView!
    
    private var sortedWeekdays: [Calendar.Weekday]!
    
    private var timesViewController: TimesViewController!
    
    private lazy var eventStore = EKEventStore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.prepareEvent()
        
        self.timesViewController.availabilities = self.event.availabilities.sorted()
        
        self.prepareWeekdaySegmentedControl()
        
        self.title = self.event.name
        
        if let user = User.current
        {
            if self.event.joinedUsers.contains(user)
            {
                self.state = .joined
            }
        }
        
        self.update()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if User.current == nil
        {
            let alertController = UIAlertController(title: "Private Event", message: "Please log in to view your invitation and join this event.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard segue.identifier == "embedTimesViewController" else { return }
        
        self.timesViewController = segue.destination as! TimesViewController
        self.timesViewController.weekday = .monday
    }
}

private extension EventViewController
{
    func update()
    {
        if User.current != nil
        {
            self.blurView.isHidden = true
            self.confirmButton.isEnabled = true
            
            switch self.state
            {
            case .viewing:
                self.navigationItem.rightBarButtonItem = nil
                self.confirmButton.setTitle("Join Event", for: .normal)
                
            case .addingAvailabilities:
                self.navigationItem.rightBarButtonItem = self.importCalendarButton
                self.confirmButton.setTitle("Submit", for: .normal)
                
            case .joined:
                self.navigationItem.rightBarButtonItem = self.leaveEventButton
                self.confirmButton.setTitle("Submit", for: .normal)
            }
        }
        else
        {
            self.blurView.isHidden = false
            self.confirmButton.isEnabled = false
        }
    }
    
    func uploadEvent()
    {
        print("Uploading event...")
    }
}

private extension EventViewController
{
    func prepareEvent()
    {
        if self.event == nil
        {
            self.event = Event()
            self.event.name = "201 Meeting"
            self.event.creator = User.current
        }        
        
        self.event.availabilities = Set(self.generateRandomAvailabilities())
    }
    
    func generateRandomAvailabilities() -> [Availability]
    {
        let source = GKARC4RandomSource(seed: "hello world".data(using: .utf8)!)
        source.dropValues(1200)
        
        let users = ["Tyler", "Alex", "Gordon", "Yuchuan", "Will"].map { (name) -> User in
            let user = User(name: name, email: "email", id: 0)
            return user
        }
        
        var availabilites = [Availability]()
        
        for _ in 0 ..< 40
        {
            let availability = self.randomAvailability(from: users, using: source)
            availabilites.append(availability)
        }
        
        availabilites.sort()
        
        availabilites.forEach { print($0) }
        
        return availabilites
    }
    
    func randomAvailability(from users: [User], using source: GKARC4RandomSource) -> Availability
    {
        let user = users[source.nextInt(upperBound: users.count)]
        let day = Calendar.Weekday.allValues[source.nextInt(upperBound: Calendar.Weekday.allValues.count)]
        
        while true
        {
            let hour1 = source.nextInt(upperBound: 12) + 8
            let hour2 = source.nextInt(upperBound: 12) + 8
            
            if hour1 == hour2
            {
                continue
            }
            
            let startDate = DateComponents(calendar: Calendar.current, hour: min(hour1, hour2), weekday: day.rawValue, weekdayOrdinal: 1).date!
            let endDate = DateComponents(calendar: Calendar.current, hour: max(hour1, hour2), weekday: day.rawValue, weekdayOrdinal: 1).date!
            
            let interval = DateInterval(start: startDate, end: endDate)
            
            let availability = Availability(user: user, interval: interval)
            return availability
        }
        
        fatalError()
    }
    
    func prepareWeekdaySegmentedControl()
    {
        self.sortedWeekdays = Set(self.event.availabilities.map { $0.interval.weekday }).sorted { $0.rawValue < $1.rawValue }
        
        self.weekdaySegmentedControl.removeAllSegments()
        
        for weekday in self.sortedWeekdays.reversed()
        {
            self.weekdaySegmentedControl.insertSegment(withTitle: weekday.localizedAbbreviation, at: 0, animated: false)
        }
        
        self.weekdaySegmentedControl.selectedSegmentIndex = 0
        self.timesViewController.weekday = self.sortedWeekdays[0]
    }
}

extension EventViewController
{
    @IBAction func updateWeekday(with sender: UISegmentedControl)
    {
        let weekday = self.sortedWeekdays[sender.selectedSegmentIndex]
        self.timesViewController.weekday = weekday
    }
    
    @IBAction func pressedConfirmButton(with sender: UIButton)
    {
        guard let user = User.current else { return }
        
        switch self.state
        {
        case .viewing: self.state = .addingAvailabilities
        case .addingAvailabilities, .joined:
            let filteredAvailabilities = self.timesViewController.availabilities.filter { $0.user == User.current }
            self.event.availabilities.formUnion(filteredAvailabilities)
            
            self.event.joinedUsers.insert(user)
            self.state = .joined
        }
        
        self.update()
    }
    
    @IBAction func leaveEvent(with sender: UIBarButtonItem)
    {
        guard let user = User.current else { return }
        
        self.event.joinedUsers.remove(user)
        self.state = .viewing
        
        self.timesViewController.availabilities = self.timesViewController.availabilities.filter { $0.user != User.current }
        
        self.timesViewController.collectionView?.reloadData()
        self.update()
    }
    
    @IBAction func importCalendar(with sender: UIBarButtonItem)
    {
        guard let user = User.current else { return }
        
        self.eventStore.requestAccess(to: .event) { (success, error) in
            let date = Date()
            
            let predicate = self.eventStore.predicateForEvents(withStart: date.currentWeekStart, end: date.currentWeekEnd, calendars: nil)
            
            let events = self.eventStore.events(matching: predicate).sorted(by: { $0.startDate < $1.endDate })
            
            var dateIntervals = [DateInterval]()
            
            let weekStartDate = DateComponents(calendar: Calendar.current, weekday: Calendar.Weekday.sunday.rawValue, weekdayOrdinal: 1).date!
            
            for weekday in self.sortedWeekdays
            {
                var startDate = Calendar.current.date(byAdding: .day, value: (weekday.rawValue - 1), to: weekStartDate)!
                let endDate = Calendar.current.date(byAdding: .hour, value: 23, to: startDate)!
                
                startDate = Calendar.current.date(byAdding: .hour, value: 8, to: startDate)!
                
                var dateInterval = DateInterval(start: startDate, end: endDate)
                
                let filteredEvents = events.filter { Calendar.current.component(.weekday, from: $0.startDate) == weekday.rawValue }
                for event in filteredEvents
                {
                    let startHour = Calendar.current.component(.hour, from: event.startDate)
                    let eventStartDate = Calendar.current.date(byAdding: .hour, value: startHour - 8, to: startDate)!
                    
                    var components = Calendar.current.dateComponents([.hour, .minute], from: event.endDate)
                    if components.minute! > 0
                    {
                        components.hour = components.hour! + 1
                        components.minute = 0
                    }
                    
                    let eventEndDate = Calendar.current.date(byAdding: .hour, value: components.hour! - 8, to: startDate)!
                    
                    if dateInterval.start < eventStartDate
                    {
                        let interval = DateInterval(start: dateInterval.start, end: eventStartDate)
                        dateIntervals.append(interval)
                    }
                    
                    dateInterval = DateInterval(start: eventEndDate, end: endDate)
                }
                
                dateIntervals.append(dateInterval)
            }
            
            let availabilities = dateIntervals.filter { $0.duration >= 3600 }.map { Availability(user: user, interval: $0) }
            
            self.timesViewController.availabilities.append(contentsOf: availabilities)
            
            DispatchQueue.main.async {
                self.timesViewController.collectionView?.reloadData()
                
                self.update()
            }
        }
    }
}
