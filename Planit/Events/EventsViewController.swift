//
//  EventsViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/27/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension EventsViewController
{
    enum EventsFilter: Int
    {
        case created
        case joined
        case invited
    }
}

class EventsViewController: UITableViewController
{
    var eventsFilter: EventsFilter = .created
    
    var createdEvents = [Event]()
    var joinedEvents = [Event]()
    var invitedEvents = [Event]()
    
    private var events: [Event] {
        switch self.eventsFilter
        {
        case .created: return self.createdEvents
        case .joined: return self.joinedEvents
        case .invited: return self.invitedEvents
        }
    }
    
    @IBOutlet private var eventsFilterSegmentedControl: UISegmentedControl!
    @IBOutlet private var eventsFilterSegmentedControlContainerView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.eventsFilterSegmentedControlContainerView
        
        let users = ["Tyler", "Alex", "Gordon", "Yuchuan", "Will"].map { (name) -> User in
            var user = User()
            user.name = name
            return user
        }
        
        self.createdEvents = [
            Event(name: "Event 1", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0]]),
            Event(name: "Event 2", creator: User.current!, isPublic: false, invitedEmails: ["1", "2", "3"], joinedUsers: [users[1], users[2]]),
            Event(name: "Event 3", creator: User.current!, isPublic: false, invitedEmails: ["1", "2", "3", "5", "6", "7"], joinedUsers: [users[3], users[4], users[0], users[1], users[2]]),
            Event(name: "Event 4", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0], users[1]]),
            Event(name: "Event 5", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0]]),
        ]
        
        self.joinedEvents = [
            Event(name: "Joined Event 1", creator: users[0], isPublic: false, invitedEmails: ["1", "2", "3", "4", "5"], joinedUsers: [User.current!]),
            Event(name: "Joined Event 2", creator: users[1], isPublic: true, invitedEmails: [], joinedUsers: [users[1], User.current!]),
            Event(name: "Joined Event 3", creator: users[2], isPublic: false, invitedEmails: ["1", "2", "3", "5", "6", "7"], joinedUsers: [users[3], users[4], users[0], users[1], User.current!]),
        ]
        
        self.invitedEvents = [
            Event(name: "Invited Event 1", creator: users[0], isPublic: false, invitedEmails: ["1", "2", "3"], joinedUsers: []),
            Event(name: "Invited Event 2", creator: users[1], isPublic: false, invitedEmails: ["1"], joinedUsers: [users[1]]),
        ]
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        switch identifier
        {
        case "event":
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            
            let event = self.events[indexPath.row]
            
            let eventViewController = segue.destination as! EventViewController
            eventViewController.event = event
            
        case "newEvent": break
        default: break
        }
    }
}

private extension EventsViewController
{
    func update()
    {
        self.tableView.reloadData()
    }
}

private extension EventsViewController
{
    @IBAction func changeEventsFilter(with sender: UISegmentedControl)
    {
        let filter = EventsFilter(rawValue: sender.selectedSegmentIndex)!
        self.eventsFilter = filter
        
        self.update()
    }
    
    @IBAction func logOut(with sender: UIBarButtonItem)
    {
        User.current = nil
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension EventsViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let event = self.events[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventsTableViewCell
        cell.roundedBackgroundView.backgroundColor = UIColor.contentColors[indexPath.row]
        cell.creatorLabel.text = "By " + event.creator.name
        cell.eventNameLabel.text = event.name
        
        if event.isPublic
        {
            cell.joinedUsersStackView.isHidden = true
            
            cell.invitedUsersCountLabel.text = event.joinedUsers.count.description
            cell.joinedUsersCountLabel.text = "0"
            
            cell.isPrivateImageView.isHidden = true
        }
        else
        {
            cell.joinedUsersStackView.isHidden = false
            
            cell.invitedUsersCountLabel.text = event.invitedEmails.count.description
            cell.joinedUsersCountLabel.text = event.joinedUsers.count.description
            
            cell.isPrivateImageView.isHidden = false
        }
        
        return cell
    }
}
