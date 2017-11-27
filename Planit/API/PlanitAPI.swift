//
//  PlanitAPI.swift
//  Planit
//
//  Created by Caroline Moore on 11/6/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation
import SwiftSocket

class PlanitAPI
{
    static let shared = PlanitAPI()
    let client = TCPClient(address: "127.0.0.1", port: 6789)
    var connected : Bool
    var currentUser : User? = nil
    
    private init()
    {
        connected = false
    }
    
    func connect()
    {
        switch client.connect(timeout: 10)
        {
        case .success:
            connected = true
        case .failure(let error):
            print(error)
        }
    }
    
    
    
    func get(eventForID: Int, completion: (Event?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        var data = EventIdJSON()
        data.type = "getevent"
        data.eventID = eventForID
        
        do
        {
            let encoder = JSONEncoder()
            let eventData = try encoder.encode(data)
            
            var dataLength = UInt32(eventData.count)
            dataLength = CFSwapInt32HostToBig(dataLength)
            
            var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
            client.send(data: dataLengthData)
            
            switch client.send(data: eventData)
            {
            case .success:
                guard let data = client.read(1024*10) else
                {
                    completion(nil)
                    return
                }
                
                let jsonData = Data(bytes: data)
                
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
    
    
    
    func get(userForID: Int, completion: (User?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
            return
        }
        
        var data = UserIdJSON()
        data.type = "getuser"
        data.userID = userForID
        
        do
        {
            let encoder = JSONEncoder()
            let eventData = try encoder.encode(data)
            
            var dataLength = UInt32(eventData.count)
            dataLength = CFSwapInt32HostToBig(dataLength)
            
            var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
            client.send(data: dataLengthData)
            
            switch client.send(data: eventData)
            {
            case .success:
                guard let data = client.read(1024*10) else
                {
                    completion(nil)
                    return
                }
                
                let jsonData = Data(bytes: data)
                
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
    
    
    
    func getEvents(ofType: String, forUser: User, completion: (Array<Event>?) -> Void)
    {
        if (connected == false)
        {
            completion(nil)
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
            let encoder = JSONEncoder()
            let eventData = try encoder.encode(data)
            
            var dataLength = UInt32(eventData.count)
            dataLength = CFSwapInt32HostToBig(dataLength)
            
            var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
            client.send(data: dataLengthData)
            
            switch client.send(data: eventData)
            {
            case .success:
                guard let data = client.read(1024*10) else
                {
                    completion(nil)
                    return
                }
                
                let jsonData = Data(bytes: data)
                
                let decoder = JSONDecoder()
                let json = try decoder.decode(EventListJSON.self, from: jsonData)
                
                let eventList = json.eventList
                
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
    
    
    
    func create(_ event: Event, completion: (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        do
        {
            var data = EventJSON()
            data.type = "createevent"
            data.event = event
            
            let encoder = JSONEncoder()
            let eventData = try encoder.encode(data)
            
            var dataLength = UInt32(eventData.count)
            dataLength = CFSwapInt32HostToBig(dataLength)
            
            var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
            client.send(data: dataLengthData)
            
            switch client.send(data: eventData)
            {
            case .success:
                guard let data = client.read(1024*10) else
                {
                    completion(false)
                    return
                }
                
                if let response = String(bytes: data, encoding: .utf8)
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
    
    
    
    func signUp(_ email: String, username: String, password: String, completion: (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        let userData = ["type": "signup", "email": email, "username": username, "password": password]
        var serializedData : Data? = nil
        
        do
        {
            serializedData = try JSONEncoder().encode(userData)
        }
        catch let error
        {
            print(error)
        }
        
        var dataLength = UInt32(serializedData!.count)
        dataLength = CFSwapInt32HostToBig(dataLength)
        
        var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
        client.send(data: dataLengthData)
        
        switch client.send(data: serializedData!)
        {
        case .success:
            guard let data = client.read(1024*10) else
            {
                completion(nil)
                return
            }
            
            let jsonData = Data(bytes: data)
            
            let decoder = JSONDecoder()
            let json = try decoder.decode(UserJSON.self, from: jsonData)
            
            let user = json.user
            self.currentUser = user
            
            completion(true)
            
        case .failure(let error):
            print(error)
            completion(false)
        }
    }
    
    
    
    func logIn(_ username: String, password: String, completion: (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        let userData = ["type": "login", "username": username, "password": password]
        var serializedData : Data? = nil
        
        do
        {
            serializedData = try JSONEncoder().encode(userData)
        }
        catch let error
        {
            print(error)
        }
        
        var dataLength = UInt32(serializedData!.count)
        dataLength = CFSwapInt32HostToBig(dataLength)
        
        var dataLengthData = Data(bytes: &dataLength, count: MemoryLayout.size(ofValue: dataLength))
        client.send(data: dataLengthData)
        
        switch client.send(data: serializedData!)
        {
            case .success:
                guard let data = client.read(1024*10) else
                {
                    completion(nil)
                    return
                }
                
                let jsonData = Data(bytes: data)
                
                let decoder = JSONDecoder()
                let json = try decoder.decode(UserJSON.self, from: jsonData)
                
                let user = json.user
                self.currentUser = user
                
                completion(true)
            
            case .failure(let error):
                print(error)
                completion(false)
        }
    }
}
