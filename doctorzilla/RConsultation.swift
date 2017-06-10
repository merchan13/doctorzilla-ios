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
	
	// Has many:
	let backgrounds = List<RBackground>()
	let physicalExams = List<RPhysicalExam>()
	
	// Belongs to:
	private let diagnostics = LinkingObjects(fromType: RDiagnostic.self, property: "consultations")
	private let reasons = LinkingObjects(fromType: RReason.self, property: "consultations")
	
	// To-one relationship:
	private let plans = LinkingObjects(fromType: RPlan.self, property: "consultations")
	
	var diagnostic: RDiagnostic {
		return self.diagnostics.first!
	}
	
	var plan: RPlan {
		return self.plans.first!
	}
	
	var reason: RReason {
		return self.reasons.first!
	}
	
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
