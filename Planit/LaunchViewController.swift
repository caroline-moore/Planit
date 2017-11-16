//
//  LaunchViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit


class LaunchViewController: UIViewController
{
    
    @IBOutlet weak var planitLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.planitLabel.attributedText = NSAttributedString(string: "planit", attributes: [NSAttributedStringKey.kern: 1.25])
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

