//
//  APIClient.swift
//  RACSignUp
//
//  Created by Hirad Motamed on 2015-10-08.
//  Copyright © 2015 Pendar Labs. All rights reserved.
//

import Foundation


enum APIError: ErrorType {
    case FailedDueToCrappyAPI
}

struct APIClient {
    func signUp(email: String, password: String, completion: (Int?, APIError?) -> Void) {
        let failureDeterminant = UInt64(arc4random_uniform(10))
        
        if failureDeterminant > 2 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                completion(nil, APIError.FailedDueToCrappyAPI)
            }
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(failureDeterminant * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                completion(Int(arc4random_uniform(100)), nil)
            }
        }
    }
}

struct DummyContext {
    func performBlock(block: () -> ()) {
        let randomWait = UInt64(arc4random_uniform(2))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(randomWait * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            block()
        }
    }
}