//
//  User.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/18/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire

class User {
    
    private var _email: String!
	private var _password: String!
    
    var email: String {
        if _email == nil {
            _email = ""
        }
        return _email
    }
    
    var password: String {
        if _password == nil {
            _password = ""
        }
        return _password
    }
    
    func signIn(email: String, password: String, completed: @escaping DownloadComplete) {
		
        let parameters: Parameters = [
            "user_login": [
                "email": email,
                "password": password
            ]
        ]
        
        Alamofire.request("\(URL_BASE)\(URL_SIGN_IN)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
			
            if let result = response.result.value as? Dictionary<String, AnyObject>{
				
                if let token = result["auth_token"] as? String {
                    AuthToken.sharedInstance.token = token
					self._email = email
					self._password = password
				} else {
					AuthToken.sharedInstance.token = ""
				}

            }
            completed()
        }
    }
    
}
