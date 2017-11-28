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
    
    private var events: [Event] {
        switch self.eventsFilter
        {
        case .created: return User.current!.createdEvents
        case .joined: return User.current!.joinedEvents
        case .invited: return User.current!.invitedEvents
        }
    }
    
    @IBOutlet private var eventsFilterSegmentedControl: UISegmentedControl!
    @IBOutlet private var eventsFilterSegmentedControlContainerView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.eventsFilterSegmentedControlContainerView
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
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
        cell.roundedBackgroundView.backgroundColor = UIColor.contentColors[indexPath.row % UIColor.contentColors.count]
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
            
            cell.invitedUsersCountLabel.text = (event.invitedEmails.count + 1).description
            cell.joinedUsersCountLabel.text = event.joinedUsers.count.description
            
            cell.isPrivateImageView.isHidden = false
        }
        
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        cell.roundedBackgroundView.clipsToBounds = false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let cell = cell as! EventsTableViewCell
        
        cell.clipsToBounds = false
        cell.contentView.clipsToBounds = false
        cell.roundedBackgroundView.clipsToBounds = false
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
    }
}
