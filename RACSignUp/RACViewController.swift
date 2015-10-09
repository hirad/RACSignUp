//
//  RACViewController.swift
//  RACSignUp
//
//  Created by Hirad Motamed on 2015-10-08.
//  Copyright © 2015 Pendar Labs. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension APIClient {
    func signalForSignUp(email: String, password: String) -> SignalProducer<Int, APIError> {
        return SignalProducer { sink, disposable in
            self.signUp(email, password: password) { maybeID, maybeError in
                if let userID = maybeID {
                    sendNext(sink, userID)
                    sendCompleted(sink)
                }
                else if let error = maybeError {
                    
                    sendError(sink, error)
                }
                else {
                    sendInterrupted(sink)
                }
            }
        }
    }
}

class RACViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private var api = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emailValidSignal = emailField.rac_text.producer
            .map { $0.isValidEmail() }
        
        let passwordValidSignal = passwordField.rac_text.producer
            .map { $0.characters.count > 0 }
        
        let passwordMatchesConfirmationSignal = combineLatest(passwordField.rac_text.producer, passwordConfirmationField.rac_text.producer).map {
            (values: (String, String)) -> Bool in
            let (password, confirmation) = values
            return password == confirmation
        }
        
        signUpButton.rac_enabled <~ combineLatest(emailValidSignal, passwordValidSignal, passwordMatchesConfirmationSignal)
            .map { (validations: (Bool, Bool, Bool)) -> Bool in
            let (emailValid, passwordValid, passwordConfirmationValid) = validations
            return emailValid && passwordValid && passwordConfirmationValid
        }
    }
    
    @IBAction private func signUp(sender: AnyObject?) {
        api.signalForSignUp(emailField.text!, password: passwordField.text!)
            .on(started: {
                self.spinner.startAnimating()
            }, terminated: { () -> () in
                self.spinner.stopAnimating()
            }, disposed: { () -> () in
                self.spinner.stopAnimating()
            })
            .retry(3)
            .start { event in
                print("Received event: \(event)")
        }
    }
}
