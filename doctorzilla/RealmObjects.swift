//
//  RealmObjects.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/7/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

// [ BACKGROUND ]
class RBackground: Object {
	dynamic var id = 0
	dynamic var backgroundType = ""
	dynamic var backgroundDescription = ""
	
	// Belongs to:
	private let consultations = LinkingObjects(fromType: RConsultation.self, property: "backgrounds")
	
	var consultation: RConsultation {
		return self.consultations.first!
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// CONSULTATION
class RConsultation: Object {
	dynamic var id = 0
	
	// Has many:
	let backgrounds = List<RBackground>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// [ INSURANCE ]
class RInsurance: Object {
	dynamic var id = 0
	dynamic var name = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// [ MEDICAL RECORD ]
class RMedicalRecord: Object {
	dynamic var id = 0
	dynamic var document = ""
	dynamic var name = ""
	dynamic var lastName = ""
	dynamic var birthday = ""
	dynamic var firstConsultation = ""
	dynamic var email = ""
	dynamic var phone = ""
	dynamic var cellphone = ""
	dynamic var address = ""
	dynamic var gender = ""
	dynamic var referredBy = ""
	dynamic var height = 0
	dynamic var weight = 0
	dynamic var pressure_d = ""
	dynamic var pressure_s = ""
	dynamic var lastUpdate = ""
	
	// Has many:
	let backgrounds = List<RBackground>()
	
	// Belongs to:
	private let users = LinkingObjects(fromType: RUser.self, property: "medrecords")
	private let occupations = LinkingObjects(fromType: ROccupation.self, property: "medrecords")
	private let insurances = LinkingObjects(fromType: RInsurance.self, property: "medrecords")
	
	var user: RUser {
		return self.users.first!
	}
	
	var occupation: ROccupation {
		return self.occupations.first!
	}
	
	var insurance: RInsurance {
		return self.insurances.first!
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// [ OCCUPATION ]
class ROccupation: Object {
	dynamic var id = 0
	dynamic var name = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// PHYSICAL EXAM
class RPhysicalExam: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

// [ USER ]
class RUser: Object {
	dynamic var id = 0
	dynamic var email = ""
	dynamic var password = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
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
}


















