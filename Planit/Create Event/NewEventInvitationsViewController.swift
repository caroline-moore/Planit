//
//  NewEventInvitationsViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension NewEventInvitationsViewController
{
    @objc(InvitationTextField)
    private class TextField: UITextField
    {
        override func rightViewRect(forBounds bounds: CGRect) -> CGRect
        {
            var rect = super.rightViewRect(forBounds: bounds)
            rect.origin.y -= 5
            return rect
        }
    }
}

class NewEventInvitationsViewController: UIViewController
{
    var event: Event!
    
    private var isReadyToUploadEvent = false
    
    private var invitedEmails = [String]()

    @IBOutlet private var publicPrivateSegmentedControl: UISegmentedControl!
    
    @IBOutlet private var inviteStackView: UIStackView!
    @IBOutlet private var inviteButton: UIButton!
    @IBOutlet private var inviteTextField: UITextField!
    @IBOutlet private var invitedPeopleCollectionView: UICollectionView!
    
    @IBOutlet private var createEventButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.inviteTextField.rightView = self.inviteButton
        self.inviteTextField.rightViewMode = .always
        
        self.validate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if self.isReadyToUploadEvent && User.current != nil
        {
            self.uploadEvent()
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let collectionViewLayout = self.invitedPeopleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.itemSize.width = (self.view.bounds.width - (30 * 2) - collectionViewLayout.minimumInteritemSpacing) / 2
        collectionViewLayout.invalidateLayout()
    }
}

private extension NewEventInvitationsViewController
{
    @IBAction func validate()
    {
        let inviteButtonEnabled = (self.inviteTextField.text?.isEmpty == false)
        self.inviteButton.isEnabled = inviteButtonEnabled
        
        let createEventButtonEnabled = (self.publicPrivateSegmentedControl.selectedSegmentIndex == 0) ? !self.invitedEmails.isEmpty : true
        self.createEventButton.isEnabled = createEventButtonEnabled
    }
    
    @IBAction func invite()
    {
        guard let emailAddress = self.inviteTextField.text else { return }
        self.invitedEmails.append(emailAddress)
        
        self.inviteTextField.text = nil
        
        self.invitedPeopleCollectionView.performBatchUpdates({
            self.invitedPeopleCollectionView.insertItems(at: [IndexPath(item: self.invitedEmails.count - 1, section: 0)])
        }, completion: nil)
        
        self.validate()
    }
    
    @IBAction func createEvent(with sender: UIButton)
    {
        self.event.isPublic = (self.publicPrivateSegmentedControl.selectedSegmentIndex == 1)
        self.event.invitedEmails = Set(self.invitedEmails)
        
        var baseURL = "plan.it/"
        baseURL.append(event.name.components(separatedBy: .whitespaces).joined())
        self.event.URL = baseURL
        
        self.event.creator = User.current
        
        if User.current == nil
        {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Not Logged In", message: "Please log in to finish creating an event.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action) in
                    self.isReadyToUploadEvent = true
                    self.performSegue(withIdentifier: "logIn", sender: nil)
                }))

                self.present(alertController, animated: true, completion: nil)
            }
        }
        else
        {
            self.uploadEvent()
        }
    }
    
    @IBAction func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer)
    {
        self.inviteTextField.resignFirstResponder()
    }
    
    @IBAction func toggleEventType(with sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.inviteStackView.tintColor = nil
            self.inviteStackView.alpha = 1.0
            
        case 1:
            self.inviteStackView.tintColor = .gray
            self.inviteStackView.alpha = 0.3
            
        default: break
        }
        
        self.validate()
    }
}

private extension NewEventInvitationsViewController
{
    func uploadEvent()
    {
        self.isReadyToUploadEvent = false
        self.event.creator = User.current
        
        print("Uploading event:", self.event)
        
        PlanitAPI.shared.create(event) { (success) in
            DispatchQueue.main.async {
                if success
                {
                    User.current?.createdEvents.append(self.event)
                    
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    let alertController = UIAlertController(title: "Failed to Create Event", message: "Please make sure you are connected to the internet and try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension NewEventInvitationsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.invitedEmails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! InvitationCollectionViewCell
        cell.textLabel.text = self.invitedEmails[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.invitedEmails.remove(at: indexPath.item)
        
        self.invitedPeopleCollectionView.performBatchUpdates({
            self.invitedPeopleCollectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
        self.validate()
    }
}
