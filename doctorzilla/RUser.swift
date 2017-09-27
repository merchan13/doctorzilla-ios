//
//  RUser.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RUser: Object {
	@objc dynamic var id = 0
	@objc dynamic var email = ""
    @objc dynamic var password = ""
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func signIn(email: String, password: String) -> Bool {
		
		if email == self.email && password == self.password {
			return true
		} else {
			return false
		}
	}
	
	// Do sign out (for offline purposes)
}
