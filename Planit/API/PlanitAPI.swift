//
//  PlanitAPI.swift
//  Planit
//
//  Created by Caroline Moore on 11/26/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import Foundation
import SwiftSocket

class PlanitAPI
{
    static let shared = PlanitAPI()
    let client = TCPClient(address: "127.0.0.1", port: 6789)
    var connected : Bool
    
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
        
        
        
        completion(true)
    }
    
    func login(_ username: String, password: String, completion: (Bool) -> Void)
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
            serializedData = try JSONSerialization.data(withJSONObject: userData)
        }
        catch let error
        {
            print(error)
        }
        
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
                    
                    if (response == "valid")
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
