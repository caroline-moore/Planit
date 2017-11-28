//
//  AuthorizationViewController.swift
//  Planit
//
//  Created by Caroline Moore on 11/5/17.
//  Copyright © 2017 Caroline Moore. All rights reserved.
//

import UIKit

extension AuthorizationViewController
{
    enum AuthorizationType
    {
        case logIn
        case signUp
    }
}

class AuthorizationViewController: UIViewController
{
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    
    @IBOutlet private var authorizeButton: UIButton!
    @IBOutlet private var switchAuthorizationTypeButton: UIButton!
    
    @IBOutlet private var emailStackView: UIStackView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var contentStackViewCenterYConstraint: NSLayoutConstraint!
    
    var authorizationType: AuthorizationType = .logIn {
        didSet {
            self.update()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthorizationViewController.keyboardWillShow(with:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AuthorizationViewController.keywordWillHide(with:)), name: .UIKeyboardWillHide, object: nil)
        
        self.update()
    }
}

private extension AuthorizationViewController
{
    func update()
    {
        guard self.isViewLoaded else { return }
        
        switch self.authorizationType
        {
        case .logIn:
            self.title = "Log In"
            self.authorizeButton.setTitle("Log In", for: .normal)
            self.emailStackView.isHidden = true
            let question = NSMutableAttributedString(string: "Don't have an account? ", attributes: [.foregroundColor: UIColor.white])
            let answer = NSAttributedString(string: "Sign up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white])
            question.append(answer)
            self.switchAuthorizationTypeButton.setAttributedTitle(question, for: .normal)
            
        case .signUp:
            self.title = "Sign Up"
            self.authorizeButton.setTitle("Sign Up", for: .normal)
            self.emailStackView.isHidden = false
            let question = NSMutableAttributedString(string: "Already have an account? ", attributes: [.foregroundColor: UIColor.white])
            let answer = NSAttributedString(string: "Log in", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white])
            question.append(answer)
            self.switchAuthorizationTypeButton.setAttributedTitle(question, for: .normal)
        }
        
        self.validate()
    }
    
    func validate()
    {
        var enabled = (self.usernameTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false)
        
        if self.authorizationType == .signUp
        {
            enabled = (enabled && self.emailTextField.text?.isEmpty == false)
        }
        
        self.authorizeButton.isEnabled = enabled
    }
    
    @IBAction func authorize()
    {
        print("Authenticating user...")
        
        User.current = User(name: "Caroline", identifier: 3)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel()
    {
        self.dismiss(animated: true, completion: nil)
    }
}

private extension AuthorizationViewController
{
    @IBAction func textFieldTextDidChange(_ sender: UITextField)
    {
        self.validate()
    }
    
    @IBAction func textFieldReturnButtonPressed(_ sender: UITextField)
    {
        switch sender
        {
        case self.emailTextField: self.usernameTextField.becomeFirstResponder()
        case self.usernameTextField: self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            sender.resignFirstResponder()
            self.authorize()
        default: sender.resignFirstResponder()
        }
    }
    
    @IBAction func switchAuthorizationType(_ sender: UIButton)
    {
        switch self.authorizationType
        {
        case .logIn: self.authorizationType = .signUp
        case .signUp: self.authorizationType = .logIn
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer)
    {
        self.emailTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
}

private extension AuthorizationViewController
{
    @objc func keyboardWillShow(with notification: Notification)
    {
        guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let convertedFrame = self.view.convert(frame, from: self.view.window)
        
        let offset = (self.contentStackView.frame.maxY - convertedFrame.minY) + 15
        self.contentStackViewCenterYConstraint.constant = -offset
        
        let animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: UISpringTimingParameters())
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    @objc func keywordWillHide(with notification: Notification)
    {
        self.contentStackViewCenterYConstraint.constant = 0
        
        let animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: UISpringTimingParameters())
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
