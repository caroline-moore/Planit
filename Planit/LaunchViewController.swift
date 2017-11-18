//
//  LaunchViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit
import Alamofire


class LaunchViewController: UIViewController
{
    
    @IBOutlet weak var planitLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.planitLabel.attributedText = NSAttributedString(string: "planit", attributes: [NSAttributedStringKey.kern: 1.25])
        let events = Event()
        let parameters: Parameters = [
            "email": "chen922@usc.edu",
            "username": "maxchen",
            "password": "secretpassword"
        ]
        Alamofire.request("https://69.26.157.179:6789", method: .connect, parameters: parameters, encoding: JSONEncoding.default)
        Alamofire.request("https://69.26.157.179:6789").responseJSON { response in
             print("jj")
            
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.description)")
            print("Result: \(response.debugDescription)") // response serialization result
        
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LaunchViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let identifier = segue.identifier else { return }
        
        guard let authorizationViewController = (segue.destination as? UINavigationController)?.topViewController as? AuthorizationViewController else { return }
        
        switch identifier
        {
        case "logIn": authorizationViewController.authorizationType = .logIn
        case "signUp": authorizationViewController.authorizationType = .signUp
        default: break
        }
    }
    
    @IBAction func unwindFromAuthorizationViewController(with seque: UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindFromCreateEventViewController(with seque: UIStoryboardSegue)
    {
    }
    
    
}

