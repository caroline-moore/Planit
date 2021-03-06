//
//  NewEventViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController
{
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var durationPicker: UIDatePicker!
    @IBOutlet private var isRecurringSwitch: UISwitch!
    
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var continueArrowImageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.durationPicker.countDownDuration = 60 * 60
    }
}

extension NewEventViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let timesViewController = segue.destination as? NewEventTimesViewController else { return }
        
        var event = Event()
        event.name = self.nameTextField.text ?? ""
        event.duration = self.durationPicker.countDownDuration
        event.isRecurring = self.isRecurringSwitch.isOn
        timesViewController.event = event
    }
}

private extension NewEventViewController
{
    func validate()
    {
        let enabled = (self.nameTextField.text?.isEmpty == false)
        self.continueButton.isEnabled = enabled
        
        if enabled
        {
            self.continueArrowImageView.tintColor = nil
        }
        else
        {
            self.continueArrowImageView.tintColor = .lightGray
        }
    }
    
    func `continue`()
    {
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    @IBAction func cancel()
    {
        self.dismiss(animated: true, completion: nil)
    }
}

private extension NewEventViewController
{
    @IBAction func textFieldTextDidChange(_ sender: UITextField)
    {
        self.validate()
    }
    
    @IBAction func textFieldReturnButtonPressed(_ sender: UITextField)
    {
        sender.resignFirstResponder()
    }
    
    @IBAction func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer)
    {
        self.nameTextField.resignFirstResponder()
    }
}
