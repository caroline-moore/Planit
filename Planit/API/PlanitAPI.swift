//
//  PlanitAPI.swift
//  Planit
//
//  Created by Caroline Moore on 11/6/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation
import SwiftSocket
import GameKit

extension Notification.Name
{
    static let updatedEvent = Notification.Name("Updated event")
}


class PlanitAPI
{
    static let shared = PlanitAPI()
    
    private var useDummyData = false
    
    let client = TCPClient(address: "172.20.10.3", port: 6789)
    var connected : Bool
    
    private let networkingQueue = DispatchQueue(label: "com.carolinemoore.PlanitAPI.networkingQueue", attributes: [.concurrent])
    private let listeningNetworkingQueue = DispatchQueue(label: "com.carolinemoore.PlanitAPI.listeningNetworkQueue", attributes: [.concurrent])
    
    private let randomSource: GKARC4RandomSource = {
        let source = GKARC4RandomSource(seed: "hello world".data(using: .utf8)!)
        source.dropValues(1200)
        return source
    }()
    
    init()
    {
        if self.useDummyData
        {
            connected = true
        }
        else
        {
            connected = false
        }
    }
    
    func connect()
    {
        self.networkingQueue.async { [weak self] in
            
            switch self?.client.connect(timeout: 10) ?? .success
            {
            case .success:
                self?.connected = true
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func receiveData() -> Data?
    {
        Thread.sleep(forTimeInterval: 0.5)
        
        guard let reversedDataLengthBytes = client.read(4) else { return nil }
        let dataLengthBytes = Array(reversedDataLengthBytes.reversed())
        
        let dataLength = UnsafePointer(dataLengthBytes).withMemoryRebound(to: UInt32.self, capacity: 1) {
            return $0.pointee
        }
        
        guard let bytes = client.read(Int(dataLength)) else
        {
            return nil
        }
        
        let data = Data(bytes: bytes)
        
        let temp = String(data: data, encoding: .utf8)!
        print(temp)
        
        return data
    }
    
    
    
    func sendData<T: Codable>(data: T) throws -> Result
    {
        let encoder = JSONEncoder()
        let eventData = try encoder.encode(data)
        
        var dataLength = UInt32(eventData.count)
        dataLength = CFSwapInt32HostToBig(dataLength)
        
        let dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
        let lengthResult = client.send(data: dataLengthData)
        switch lengthResult
        {
        case .success:
            let result = client.send(data: eventData)
            return result
            
        case .failure:
            return lengthResult
        }
    }
    
    
    
    func listenForEventUpdates()
    {
        self.listeningNetworkingQueue.async { [weak self] in
            while (self?.connected == false)
            {
            }
            
            print("Connected and listening for event updates!")
            
            while (self?.connected == true)
            {
                do
                {
                    guard let jsonData = self?.receiveData() else { continue }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(EventJSON.self, from: jsonData)
                    
                    let updatedEvent = json.event
                    
                    NotificationCenter.default.post(name: .updatedEvent, object: updatedEvent)
                }
                catch
                {
                    print(error)
                }
            }
        }
    }
    
    func stopListeningForEventUpdates()
    {
        self.connected = false
    }
    
    func getEvents(ofType: String, forUser: User, completion: @escaping (Array<Event>?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        self.networkingQueue.async {
            
            if !self.useDummyData
            {
                let (created, joined, invited) = self.generateEvents()
                
                switch ofType
                {
                case "created":
                    completion(created)
                case "joined":
                    completion(joined)
                case "invited":
                    completion(invited)
                default:
                    completion(nil)
                    return
                }
                
                return
            }
            
            var data = UserIdJSON()
            data.userID = forUser.identifier
            
            switch ofType
            {
            case "created":
                data.type = "getcreatedevents"
            case "joined":
                data.type = "getjoinedevents"
            case "invited":
                data.type = "getinvitedevents"
            default:
                completion(nil)
                return
            }
            
            do
            {
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(nil); return }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(EventListJSON.self, from: jsonData)
                    
                    let eventList = json.events
                    
                    completion(eventList)
                    
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
            catch
            {
                print(error)
            }
            
        }
    }
    
    
    
    func create(_ event: Event, completion: @escaping (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        self.networkingQueue.async {
            
            if self.useDummyData
            {
                completion(true)
                
                return
            }
            
            do
            {
                var data = EventJSON()
                data.type = "createevent"
                data.event = event
                
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let data = self.receiveData() else { completion(false); return }
                    
                    if let response = String(data: data, encoding: .utf8)
                    {
                        if (response == "true")
                        {
                            completion(true)
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
            catch
            {
                print(error)
            }
        }
    }
    
    
    func update(_ event: Event, completion: @escaping (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        self.networkingQueue.async {
            
            if self.useDummyData
            {
                completion(true)
                
                return
            }
            
            do
            {
                var data = EventJSON()
                data.type = "updateevent"
                data.event = event
                data.user = User.current
                
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let data = self.receiveData() else { completion(false); return }
                    
                    if let response = String(data: data, encoding: .utf8)
                    {
                        if (response == "true")
                        {
                            completion(true)
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
            catch
            {
                print(error)
            }
        }
    }
    
    
    func signUp(_ email: String, username: String, password: String, completion: @escaping (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        self.networkingQueue.async {
            
            if self.useDummyData
            {
                let user = self.generateUser()
                User.current = user
                
                completion(true)
                
                return
            }
            
            let userData = ["type": "signup", "email": email, "username": username, "password": password]
            
            do
            {
                let result = try self.sendData(data: userData)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(false); return }
                    
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: jsonData)
                    
                    User.current = user
                    
                    completion(true)
                    
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
            catch
            {
                print(error)
            }
            
        }
    }
    
    
    
    func logIn(_ username: String, password: String, completion: @escaping (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        self.networkingQueue.async {
            
            if self.useDummyData
            {
                let user = self.generateUser()
                User.current = user
                
                completion(true)
                
                return
            }
            
            let userData = ["type": "login", "username": username, "password": password]
            
            do
            {
                let result = try self.sendData(data: userData)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(false); return }
                    
                    do
                    {
                        let decoder = JSONDecoder()
                        let user = try decoder.decode(User.self, from: jsonData)
                        
                        User.current = user
                        
                        completion(true)
                    }
                    catch let error
                    {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
            catch
            {
                print(error)
            }
            
        }
    }
}

private extension PlanitAPI
{
    func generateUser() -> User
    {
        let user = User(name: "Caroline", email: "carolimm@usc.edu", id: 117)
        return user
    }
    
    func generateEvents() -> ([Event], [Event], [Event])
    {
        let users = ["Tyler", "Alex", "Gordon", "Yuchuan", "Will"].map { (name) -> User in
            let user = User(name: name, email: "email", id: 0)
            return user
        }
        
        let createdEvents = [
            Event(name: "Created Event 1", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0]]),
            Event(name: "Created Event 2", creator: User.current!, isPublic: false, invitedEmails: ["1", "2", "3"], joinedUsers: [users[1], users[2]]),
            Event(name: "Created Event 3", creator: User.current!, isPublic: false, invitedEmails: ["1", "2", "3", "5", "6", "7"], joinedUsers: [users[3], users[4], users[0], users[1], users[2]]),
            Event(name: "Created Event 4", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0], users[1]]),
            Event(name: "Created Event 5", creator: User.current!, isPublic: true, invitedEmails: [], joinedUsers: [users[0]]),
        ]
        
        let joinedEvents = [
            Event(name: "Joined Event 1", creator: users[0], isPublic: false, invitedEmails: ["1", "2", "3", "4", "5"], joinedUsers: [User.current!]),
            Event(name: "Joined Event 2", creator: users[1], isPublic: true, invitedEmails: [], joinedUsers: [users[1], User.current!]),
            Event(name: "Joined Event 3", creator: users[2], isPublic: false, invitedEmails: ["1", "2", "3", "5", "6", "7"], joinedUsers: [users[3], users[4], users[0], users[1], User.current!]),
        ]
        
        let invitedEvents = [
            Event(name: "Invited Event 1", creator: users[0], isPublic: false, invitedEmails: ["1", "2", "3"], joinedUsers: []),
            Event(name: "Invited Event 2", creator: users[1], isPublic: false, invitedEmails: ["1"], joinedUsers: [users[1]]),
        ]
        
        func update(_ event: Event) -> Event
        {
            var event = event
            
            let (availabilities, intervals) = self.generateRandomAvailabilities(for: event)
            event.availabilities = Set(availabilities)
            event.availabilityIntervals = intervals
            
            return event
        }
        
        let updatedCreatedEvents = createdEvents.map(update)
        let updatedJoinedEvents = joinedEvents.map(update)
        let updatedInvitedEvents = invitedEvents.map(update)
        
        return (updatedCreatedEvents, updatedJoinedEvents, updatedInvitedEvents)
    }
    
    func generateRandomAvailabilities(for event: Event) -> ([Availability], [DateInterval])
    {
        let users = ["Tyler", "Alex", "Gordon", "Yuchuan", "Will"].map { (name) -> User in
            let user = User(name: name, email: "email", id: 0)
            return user
        }
        
        var availabilites = [Availability]()
        var availabilityIntervals = [DateInterval]()
        
        for _ in 0 ..< 40
        {
            let availability = self.randomAvailability(from: users, using: self.randomSource)
            availabilites.append(availability)
        }
        
        for _ in 0 ..< 20
        {
            let availability = self.randomAvailability(from: users, using: self.randomSource)
            availabilityIntervals.append(availability.interval)
        }
        
        availabilites.sort()
        
        availabilites.forEach { print($0) }
        
        return (availabilites, availabilityIntervals)
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
}
