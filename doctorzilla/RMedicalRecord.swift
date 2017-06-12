//
//  RMedicalRecord.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

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
	dynamic var profilePic = NSData()
	
	// Has many:
	let backgrounds = List<RBackground>()
	let consultations = List<RConsultation>()
	
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
