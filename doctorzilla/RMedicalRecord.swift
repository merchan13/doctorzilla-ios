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
	@objc dynamic var id = 0
	@objc dynamic var hv = ""
	@objc dynamic var document = ""
	@objc dynamic var name = ""
	@objc dynamic var lastName = ""
	@objc dynamic var birthday = ""
	@objc dynamic var firstConsultation = ""
	@objc dynamic var email = ""
	@objc dynamic var phone = ""
	@objc dynamic var cellphone = ""
	@objc dynamic var address = ""
	@objc dynamic var gender = ""
	@objc dynamic var referredBy = ""
	@objc dynamic var height = 0
	@objc dynamic var weight = 0
	@objc dynamic var pressure_d = ""
	@objc dynamic var pressure_s = ""
	@objc dynamic var lastUpdate = Date()
	@objc dynamic var profilePicURL = ""
	@objc dynamic var profilePic = NSData()
	@objc dynamic var important = false
	@objc dynamic var user: RUser?
	@objc dynamic var occupation: ROccupation?
	@objc dynamic var insurance: RInsurance?
	
	// Has many:
	let consultations = List<RConsultation>()
	let backgrounds = List<RBackground>()
	let attachments = List<RAttachment>()
	let reports = List<RReport>()
	
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	
	func age() -> Int {
		var age = 0
		
		let dateFormatter = DateFormatter()
		
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		if let date = dateFormatter.date(from: self.birthday) {
			let components = Calendar.current.dateComponents([.year], from: date, to: Date())
			
			age = components.year!
		}
		
		return age
	}
	
	
	func IMC() -> Double {
		if self.weight != 0 && self.height != 0 {
			let imc = ((Double(self.weight))/(pow(Double(self.height)/100, 2)) * 100).rounded() / 100
			return imc
		} else {
			return 0.0
		}
	}
	
	
	func parsedFirstConsultationDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		
		if let date: Date = dateFormatterGet.date(from: self.firstConsultation){
			parsedDate = dateFormatterResult.string(from: date)
		}
		
		return parsedDate
	}
	
	
	func parsedBirthdayDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		if let date: Date = dateFormatterGet.date(from: self.birthday) {
			parsedDate = dateFormatterResult.string(from: date)
		}
		
		return parsedDate
	}
	
	
	func birthdayToDate() -> Date {
		let date = Date()
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		if let date: Date = dateFormatter.date(from: self.birthday) {
			return date
		}
		
		return date
	}
	
	
	func diagnostics() -> [RDiagnostic] {
	
		var sortedDiagnostics = [RDiagnostic]()
		
		for consultation in self.consultations {
			
			if consultation.diagnostics.count > 0 {
				
				sortedDiagnostics.append(contentsOf: consultation.diagnostics)
			}
		}
		
		sortedDiagnostics.sort(by: { $0.lastUpdate > $1.lastUpdate })
		
		return sortedDiagnostics
	}
	
	
	func operativeNotes() -> [ROperativeNote] {
		
		var sortedNotes = [ROperativeNote]()
		
		for consultation in self.consultations {
			
			if let plan = consultation.plan {
				
				if let opNote = plan.operativeNote {
					
					sortedNotes.append(opNote)
				}
			}
		}
		
		sortedNotes.sort(by: { $0.date > $1.date })
		
		return sortedNotes
	}
}









