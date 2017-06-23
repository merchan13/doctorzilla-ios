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
	dynamic var recordId = 0
	
	// Has many:
	let backgrounds = List<RBackground>()
	let physicalExams = List<RPhysicalExam>()
		
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func IMC() -> Double {
		if self.weight != 0 && self.height != 0 {
			let imc = ((Double(self.weight))/(pow(Double(self.height)/100, 2)) * 100).rounded() / 100
			return imc
		} else {
			return 0.0
		}
	}
	
	func parsedConsultationDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
	
		if let date: Date = dateFormatterGet.date(from: self.date){
			parsedDate = dateFormatterResult.string(from: date)
		}
		
		return parsedDate
	}
}
