//
//  RPlan.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RPlan: Object {
	@objc dynamic var id = 0
	@objc dynamic var planDescription = ""
	@objc dynamic var emergency = false
	@objc dynamic var consultationId = 0
	
	@objc dynamic var operativeNote: ROperativeNote?
	
	let procedures = List<RProcedure>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
