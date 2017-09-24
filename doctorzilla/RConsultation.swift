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
	@objc dynamic var id = 0
	@objc dynamic var date = ""
	@objc dynamic var affliction = ""
	@objc dynamic var evolution = ""
	@objc dynamic var height = 0
	@objc dynamic var weight = 0
	@objc dynamic var pressure_s = ""
	@objc dynamic var pressure_d = ""
	@objc dynamic var note = ""
	@objc dynamic var reason: RReason?
	@objc dynamic var plan: RPlan?
	@objc dynamic var lastUpdate = Date()
	@objc dynamic var recordId = 0
	
	// Has many:
	let physicalExams = List<RPhysicalExam>()
	let diagnostics = List<RDiagnostic>()
		
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
