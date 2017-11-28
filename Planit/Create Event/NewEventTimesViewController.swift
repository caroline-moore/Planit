//
//  NewEventTimesViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/12/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class NewEventTimesViewController: UIViewController
{
    var event: Event!
    
    private var selectedWeekday: Calendar.Weekday = .sunday {
        didSet {
            self.timesViewController.weekday = self.selectedWeekday
        }
    }
    
    private var isAvailableAllDay = [Calendar.Weekday: Bool]()
    
    @IBOutlet var isAvailableAllDayButton: UISwitch!
    
    @IBOutlet private var sundayButton: UIButton!
    @IBOutlet private var mondayButton: UIButton!
    @IBOutlet private var tuesdayButton: UIButton!
    @IBOutlet private var wednesdayButton: UIButton!
    @IBOutlet private var thursdayButton: UIButton!
    @IBOutlet private var fridayButton: UIButton!
    @IBOutlet private var saturdayButton: UIButton!
    
    @IBOutlet private var dayPickerButton: UIButton!
    
    @IBOutlet private var dayPickerView: UIPickerView!
    
    @IBOutlet private var timesViewControllerContainerView: UIView!
    
    private var timesViewController: TimesViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for weekday in Calendar.Weekday.allValues
        {
            self.isAvailableAllDay[weekday] = true
        }
        
        self.update()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "embedTimesViewController":
            self.timesViewController = segue.destination as! TimesViewController
            self.timesViewController.weekday = self.selectedWeekday
            
        case "continue":
            guard let invitationsViewController = segue.destination as? NewEventInvitationsViewController else { return }
            
            var filteredIntervals = self.timesViewController.availabilities.map { $0.interval}.filter { (interval) in
                guard let weekday = Calendar(identifier: .gregorian).dateComponents([.weekday], from: interval.start).gregorianWeekday else { return true }
                
                let isAvailableAllDay = self.isAvailableAllDay[weekday] ?? false
                if isAvailableAllDay
                {
                    return false
                }
                
                switch weekday
                {
                case .sunday: return self.sundayButton.isSelected
                case .monday: return self.mondayButton.isSelected
                case .tuesday: return self.tuesdayButton.isSelected
                case .wednesday: return self.wednesdayButton.isSelected
                case .thursday: return self.thursdayButton.isSelected
                case .friday: return self.fridayButton.isSelected
                case .saturday: return self.saturdayButton.isSelected
                }
            }
            
            for weekday in Calendar.Weekday.allValues
            {
                let isEnabled: Bool
                
                switch weekday
                {
                case .sunday: isEnabled = self.sundayButton.isSelected
                case .monday: isEnabled = self.mondayButton.isSelected
                case .tuesday: isEnabled = self.tuesdayButton.isSelected
                case .wednesday: isEnabled = self.wednesdayButton.isSelected
                case .thursday: isEnabled = self.thursdayButton.isSelected
                case .friday: isEnabled = self.fridayButton.isSelected
                case .saturday: isEnabled = self.saturdayButton.isSelected
                }
                
                guard isEnabled else { continue }
                
                let calendar = Calendar(identifier: .gregorian)

                let isAvailableAllDay = self.isAvailableAllDay[weekday] ?? false
                if isAvailableAllDay
                {
                    let collectionViewLayout = self.timesViewController.collectionViewLayout as! CalendarViewLayout

                    var startComponents = calendar.dateComponents([.hour, .minute, .timeZone], from: collectionViewLayout.visibleDateInterval.start)
                    startComponents.weekdayOrdinal = 1
                    startComponents.gregorianWeekday = weekday

                    var endComponents = calendar.dateComponents([.hour, .minute, .timeZone], from: collectionViewLayout.visibleDateInterval.end)
                    endComponents.weekdayOrdinal = 1
                    endComponents.gregorianWeekday = weekday
                    endComponents.hour = 23
                    endComponents.minute = 59

                    let interval = DateInterval(start: calendar.date(from: startComponents)!, end: calendar.date(from: endComponents)!)
                    filteredIntervals.append(interval)
                }
            }
            
            self.event.availabilityIntervals = filteredIntervals
            invitationsViewController.event = self.event
            
        default: break
        }
    }
}

private extension NewEventTimesViewController
{
    func update()
    {
        let title = self.selectedWeekday.localizedName + " " + "▾"
        self.dayPickerButton.setTitle(title, for: .normal)
        
        if self.isAvailableAllDay[self.selectedWeekday] ?? false
        {
            self.timesViewControllerContainerView.alpha = 0.3
            self.timesViewControllerContainerView.isUserInteractionEnabled = false
            
            self.isAvailableAllDayButton.isOn = true
        }
        else
        {
            self.timesViewControllerContainerView.alpha = 1.0
            self.timesViewControllerContainerView.isUserInteractionEnabled = true
            
            self.isAvailableAllDayButton.isOn = false
        }
    }
}

private extension NewEventTimesViewController
{
    @IBAction func `continue`()
    {
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    @IBAction func presentDayPicker(with sender: UIButton)
    {
        self.dayPickerView.selectRow(self.selectedWeekday.rawValue - 1, inComponent: 0, animated: false)
        self.dayPickerView.isHidden = !self.dayPickerView.isHidden
        
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: UISpringTimingParameters())
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    @IBAction func pressedDayButton(_ sender: UIButton)
    {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func pressedAllDayButton(_ sender: UIButton)
    {
        self.isAvailableAllDay[self.selectedWeekday] = !(self.isAvailableAllDay[self.selectedWeekday] ?? false)
        
        self.update()
    }
}

extension NewEventTimesViewController: UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let day = Calendar.Weekday(rawValue: row + 1)!
        return day.localizedName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let day = Calendar.Weekday(rawValue: row + 1)!
        self.selectedWeekday = day
        
        self.update()
    }
}
