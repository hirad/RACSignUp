//
//  ViewController.swift
//  RACSignUp
//
//  Created by Hirad Motamed on 2015-10-08.
//  Copyright © 2015 Pendar Labs. All rights reserved.
//

import UIKit

extension String {
    func isValidEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
        let isEmail = regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
        return isEmail
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private var api = APIClient()
    
    private var retryCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        notificationCenter.addObserver(self, selector: "emailChanged:", name: UITextFieldTextDidChangeNotification, object: emailField)
        notificationCenter.addObserver(self, selector: "passwordChanged:", name: UITextFieldTextDidChangeNotification, object: passwordField)
        notificationCenter.addObserver(self, selector: "passwordConfirmationChanged:", name: UITextFieldTextDidChangeNotification, object: passwordConfirmationField)
        validateForm()
        spinner.stopAnimating()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    private dynamic func emailChanged(notification: NSNotification) {
        validateForm()
    }
    
    private dynamic func passwordChanged(notification: NSNotification) {
        validateForm()
    }
    
    private dynamic func passwordConfirmationChanged(notification: NSNotification) {
        validateForm()
    }
    
    private func validateForm() {
        signUpButton.enabled = isFormValid()
    }
    
    private func isFormValid() -> Bool {
        guard let email = emailField.text,
            pw1 = passwordField.text,
            pw2 = passwordConfirmationField.text else {
            return false
        }
        
        return email.isValidEmail() && pw1.characters.count > 8 && pw1 == pw2
    }
    
    @IBAction private func signUp(sender: AnyObject?) {
        spinner.startAnimating()
        
        api.signUp(emailField.text!, password: passwordField.text!) { maybeID, maybeError in
            self.spinner.stopAnimating()
            
            if let userID = maybeID {
                print("YAY! Got a user ID: \(userID)!")
            }
            else if let error = maybeError {
                if self.retryCount < 3 {
                    self.retryCount++
                    print("Retrying for \(self.retryCount)th time")
                    self.signUp(nil)
                }
                else {
                    print("Nooooo! Failed with error: \(error)")
                }
            }
            else {
                print("No idea what happened!")
            }
            
        }
    }
    
}

