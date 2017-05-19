//
//  AuthToken.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/18/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class AuthToken {

    static var sharedInstance = AuthToken()
    private init() {}
    
    var token: String!
    
}
