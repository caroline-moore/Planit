//
//  PlanitAPI.swift
//  Planit
//
//  Created by Caroline Moore on 11/6/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation
import SwiftSocket

extension Notification.Name
{
    static let updatedEvent = Notification.Name("Updated event")
}


class PlanitAPI
{
    static let shared = PlanitAPI()
    let client = TCPClient(address: "172.20.10.3", port: 6789)
    var connected : Bool
    
    private let networkingQueue = DispatchQueue(label: "com.carolinemoore.PlanitAPI.networkingQueue", attributes: [.concurrent])
    
    init()
    {
        connected = false
    }
    
    func connect()
    {
        self.networkingQueue.async {
            
            switch self.client.connect(timeout: 10)
            {
            case .success:
                self.connected = true
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func receiveData() -> Data?
    {
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
    
    
    
    func listenForUpdates(forEvent: Event)
    {
        while (true)
        {
            do
            {
                guard let jsonData = self.receiveData() else { continue }
                
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
    
    
    
    func get(eventForID: Int, completion: @escaping (Event?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        self.networkingQueue.async {
            
            var data = EventIdJSON()
            data.type = "getevent"
            data.eventID = eventForID
            
            do
            {
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(nil); return }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(EventJSON.self, from: jsonData)
                    
                    let event = json.event
                    
                    completion(event)
                    
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
    
    
    
    func get(userForID: Int, completion: @escaping (User?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        self.networkingQueue.async {
            
            var data = UserIdJSON()
            data.type = "getuser"
            data.userID = userForID
            
            do
            {
                let result = try self.sendData(data: data)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(nil); return }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(UserJSON.self, from: jsonData)
                    
                    let user = json.user
                    
                    completion(user)
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
    
    
    
    func getEvents(ofType: String, forUser: User, completion: @escaping (Array<Event>?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        self.networkingQueue.async {
            
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
    
    
    
    func signUp(_ email: String, username: String, password: String, completion: @escaping (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        self.networkingQueue.async {
            
            let userData = ["type": "signup", "email": email, "username": username, "password": password]
            
            do
            {
                let result = try self.sendData(data: userData)
                
                switch result
                {
                case .success:
                    guard let jsonData = self.receiveData() else { completion(false); return }
                    
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(UserJSON.self, from: jsonData)
                    
                    let user = json.user
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
                        let json = try decoder.decode(UserJSON.self, from: jsonData)
                        
                        let user = json.user
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
