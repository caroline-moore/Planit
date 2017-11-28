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
                print("Successfully connected!")
                self?.connected = true
            case .failure(let error):
                print("Failed to connect :(")
                print(error)
            }
            
        }
    }
    
    func receiveData() -> Data?
    {
        Thread.sleep(forTimeInterval: 1.0)
        
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
        encoder.outputFormatting = .prettyPrinted
        
        let eventData = try encoder.encode(data)
        
        let temp = String(data: eventData, encoding: .utf8)!
        print(temp)
        
        var dataLength = UInt32(eventData.count)
        
        dataLength = CFSwapInt32HostToBig(dataLength)
        
        let dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
        let lengthResult = client.send(data: dataLengthData)
        switch lengthResult
        {
        case .success:
            
            var remaining = eventData.count
            var index = 0
            
            while remaining > 0
            {
                let length = min(512, remaining)
                
                let data = eventData[index..<index + length]
                let result = client.send(data: data)
                if case let .failure(error) = result
                {
                    print(error)
                    return result
                }
                
                remaining -= length
                index += length
            }
            
            return .success
            
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
                    let updatedEvent = try decoder.decode(Event.self, from: jsonData)
                    
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
    
    func getEvents(for user: User, completion: @escaping (([Event], [Event], [Event])?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        self.networkingQueue.async {
            
            if self.useDummyData
            {
                let events = self.generateCarolineEvents()
                completion(events)
                
                return
            }
            
            var data = UserIdJSON()
            data.userID = user.identifier
            data.type = "getevents"
            
            do
            {
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(nil); return }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(UserEventsJSON.self, from: jsonData)
                    
                    let events = (json.createdEvents, json.joinedEvents, json.invitedEvents)
                    completion(events)
                    
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
                
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    
                    guard let data = self.receiveData() else { completion(false); return }
                    
                    if let response = String(data: data, encoding: .utf8)
                    {
                        if (response == "success")
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
                User.current = User.caroline
                
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
    
    func generateCarolineEvents() -> ([Event], [Event], [Event])
    {
        let users = ["Tyler", "Alex", "Gordon", "Caroline", "Maddie"].map { (name) -> User in
            let user = User(name: name, email: "email", id: 0)
            return user
        }
        
        var event1 = Event(name: "270 Study Group", creator: User.caroline, isPublic: true, invitedEmails: [], joinedUsers: [User.caroline, users[0]])
        event1.availabilities = {
            
            func availability(for tuple: (Calendar.Weekday, Int, Int), user: User) -> Availability
            {
                let dateComponents = DateComponents(hour: tuple.1, weekday: tuple.0.rawValue, weekdayOrdinal: 1)
                
                let date = Calendar.current.date(from: dateComponents)!
                
                let interval = DateInterval(start: date, duration: TimeInterval((tuple.2 - tuple.1) * 60 * 60))
                
                let availability = Availability(user: user, interval: interval)
                return availability
            }
            
            let carolineAvailabilities = [(Calendar.Weekday.monday, 8, 12), (.monday, 16, 18), (.monday, 21, 23),
                                          (.tuesday, 8, 11), (.tuesday, 13, 14), (.tuesday, 16, 19)].map { return availability(for: $0, user: .caroline) }
            
            let tylerAvailabilities = [(Calendar.Weekday.monday, 8, 15), (.monday, 17, 23),
                                       (.tuesday, 8, 11), (.tuesday, 13, 15), (.tuesday, 17, 18), (.tuesday, 20, 23)].map { return availability(for: $0, user: .tyler) }
            
            let alexAvailabilities = [(Calendar.Weekday.monday, 10, 12), (.monday, 13, 15), (.monday, 17, 19), (.monday, 21, 23),
                                      (.tuesday, 8, 11), (.tuesday, 14, 16), (.tuesday, 17, 18), (.tuesday, 20, 23)].map { return availability(for: $0, user: .alex) }
            
            let gordonAvailabilities = [(Calendar.Weekday.monday, 8, 11), (.monday, 13, 18),
                                      (.tuesday, 8, 11), (.tuesday, 15, 23)].map { return availability(for: $0, user: .gordon) }
            
            let availabilities = carolineAvailabilities + tylerAvailabilities + alexAvailabilities + gordonAvailabilities
            return Set(availabilities)
        }()
        event1.availabilityIntervals = {
            
            var intervals = [DateInterval]()
            
            for weekday in Calendar.Weekday.allValues[1..<Calendar.Weekday.allValues.count - 1]
            {
                let date = DateComponents(calendar: Calendar.current, hour: 10, weekday: weekday.rawValue, weekdayOrdinal: 1).date!
                
                let interval = DateInterval(start: date, duration: 3600)
                intervals.append(interval)
            }
            
            return intervals
        }()
        
        let event2 = Event(name: "ITP-342 Project", creator: User.caroline, isPublic: false, invitedEmails: ["1", "2", "3"], joinedUsers: [users[1], users[2]])
        let event3 = Event(name: "Accounting Project", creator: User.caroline, isPublic: false, invitedEmails: ["1", "2", "3", "5", "6", "7"], joinedUsers: [users[3], users[4], users[0], users[1], users[2]])
        let event4 = Event(name: "Thanksgiving Dinner", creator: User.caroline, isPublic: true, invitedEmails: [], joinedUsers: [users[0], users[1]])
        let event5 = Event(name: "Weekend Retreat", creator: User.caroline, isPublic: true, invitedEmails: [], joinedUsers: [users[0]])
        
        let event6 = Event(name: "Birthday Party", creator: User.tyler, isPublic: false, invitedEmails: ["carolimm@usc.edu"], joinedUsers: [users[0]])
        
        let event7 = Event(name: "Movie Night", creator: User.tyler, isPublic: true, invitedEmails: ["carolimm@usc.edu"], joinedUsers: [User.caroline])
        
        var event201 = Event(name: "CSCI 201 Project", creator: User.caroline, isPublic: true, invitedEmails: ["carolimm@usc.edu"], joinedUsers: [User.caroline])
        event201.availabilityIntervals = event1.availabilityIntervals
        
        if User.current == User.caroline
        {
            return ([event1, event2, event3, event4, event5], [event7], [event6])
        }
        else
        {
            return ([event6, event7], [event1], [event4, event2, event201])
        }
    }
    
    /*func generateEvents() -> ([Event], [Event], [Event])
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
    }*/
}
