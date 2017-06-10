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
	dynamic var id = 0
	dynamic var planDescription = ""
	dynamic var emergency = false
	dynamic var updatedAt = ""
	
	// To-one relationship:
	let consultations = List<RConsultation>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
