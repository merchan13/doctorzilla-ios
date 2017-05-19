//
//  Login.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/12/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class Login {

    func login(email: String, password: String, completion: @escaping (Bool) -> ()) {
        
        var tokenValue: AnyObject? = nil
        
        let parameters = ["user_login": ["email": email, "password": password]]
        
        let api = APIRequest()
        
        api.postRequest(route: "sign-in", params: parameters) { (token) in
            
            if let token = token {
                
                tokenValue = token
                
            }
            
        }
        
        sleep(3)
        
        if tokenValue != nil {
            
            completion(true)
        
        } else {
        
            completion(false)
            
        }
        
    }

}
