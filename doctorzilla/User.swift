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
	
	private var _id: Int!
    private var _email: String!
	private var _password: String!
	private var _name: String!
	private var _lastName: String!
	private var _document: String!
	private var _phone: String!
	private var _error: String!
	
	var id: Int {
		if _id == nil {
			_id = 0
		}
		return _id
	}
	
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
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		return _name
	}
	
	var lastName: String {
		if _lastName == nil {
			_lastName = ""
		}
		return _lastName
	}
	
	var document: String {
		if _document == nil {
			_document = ""
		}
		return _document
	}
	
	var phone: String {
		if _phone == nil {
			_phone = ""
		}
		return _phone
	}
	
	var error: String {
		if _error == nil {
			_error = ""
		}
		return _error
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
					
					if let userId = result["user_id"] as? Int {
						
						AuthToken.sharedInstance.token = token
						
						self._id = userId
						
						self._email = email
						
						self._password = password
						
						if let userName = result["user_name"] as? String {
							self._name = userName
						}
						
						if let userLastName = result["user_last_name"] as? String {
							self._lastName = userLastName
						}
						
						if let userDocument = result["user_document"] as? String {
							self._document = userDocument
						}
						
						if let userPhone = result["user_phone"] as? String {
							self._phone = userPhone
						}
					}
					else {
						
						AuthToken.sharedInstance.token = ""
						
						self._error = "Ocurrió un error inesperado"
					}
				}
				else {
					
					AuthToken.sharedInstance.token = ""
					
					if let error_message = result["errors"] as? String {
						
						self._error = error_message
					}
				}
            }
            completed()
        }
    }
	
	func signOut(completed: @escaping DownloadComplete) {
		
		let url = "\(URL_BASE)\(URL_SIGN_OUT)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .delete, headers: headers).responseJSON { response in
			
			completed()
		}
	}
	
}
