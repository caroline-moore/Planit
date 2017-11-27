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
    let client = TCPClient(address: "localhost", port: 6789)
    
    private init()
    {
    }
    
    func connect()
    {
        switch client.connect(timeout: -1)
        {
        case .success:
            print("connected!!")
        case .failure(let error):
            print(error)
        }
    }
    
    func create(_ event: Event, completion: (Bool) -> Void)
    {
        
        
        completion(true)
    }
    
    func login(_ username: String, password: String, completion: (Bool) -> Void)
    {
        
    }
}
