//
//  RealmObjects.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/7/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RUser: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class RMedicalRecord: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class RBackground: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class RConsultation: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class RPhysicalExam: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class RInsurance: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class ROccupation: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}



/*
let owners = LinkingObjects(fromType: Owner.self, property: "dogs")

let unicorns = List<Unicorn>()

override static func primaryKey() -> String? {
	return "id"
}
*/







