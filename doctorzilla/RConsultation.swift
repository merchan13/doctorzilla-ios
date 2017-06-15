//
//  RConsultation.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RConsultation: Object {
	dynamic var id = 0
	dynamic var date = ""
	dynamic var affliction = ""
	dynamic var evolution = ""
	dynamic var height = 0
	dynamic var weight = 0
	dynamic var pressure_s = ""
	dynamic var pressure_d = ""
	dynamic var note = ""
	dynamic var diagnostic: RDiagnostic?
	dynamic var reason: RReason?
	dynamic var plan: RPlan?
	dynamic var lastUpdate = Date()
	
	// Has many:
	let backgrounds = List<RBackground>()
	let physicalExams = List<RPhysicalExam>()
		
	override static func primaryKey() -> String? {
		return "id"
	}
}
