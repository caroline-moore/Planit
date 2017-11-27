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
    
    
    
    func create(_ event: Event, completion: (Bool) -> Void)
    {
        if (connected == false)
        {
            completion(false)
            return
        }
        
        var event = event
        event.creator = self.currentUser
        
        do
        {
            var data = JSON()
            data.type = "event"
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
                    print(response)
                    
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
        
        completion(true)
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
                completion(false)
                return
            }
            
            if let response = String(bytes: data, encoding: .utf8)
            {
                print(response)
                
                if (response == "true")
                {
                    print("signed up!")
                    completion(true)
                }
                else
                {
                    print("not signed up :(")
                    completion(false)
                }
            }
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
                    completion(false)
                    return
                }
                
                if let response = String(bytes: data, encoding: .utf8)
                {
                    print(response)
                    
                    if (response == "true")
                    {
                        print("authenticated!")
                        completion(true)
                    }
                    else
                    {
                        print("not authenticated :(")
                        completion(false)
                    }
                }
            case .failure(let error):
                print(error)
                completion(false)
        }
    }
}
