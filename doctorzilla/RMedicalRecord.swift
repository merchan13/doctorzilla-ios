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
	dynamic var lastUpdate = Date()
	dynamic var profilePic = NSData()
	dynamic var user: RUser?
	dynamic var occupation: ROccupation?
	dynamic var insurance: RInsurance?
	
	// Has many:
	let consultations = List<RConsultation>()
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func backgroundsDictionary() -> [String: String] {
		var backgrounds: [String: String] = ["Familiares":"", "Alergias":"", "Diábetes":"", "Asma":"", "Cardiopatías":"", "Medicamentos":"", "Quirúrgicos":"", "Otros":""]
		
		for consultation in self.consultations {
			for bg in consultation.backgrounds {
				if let description = backgrounds[bg.backgroundDescription] {
					backgrounds[bg.backgroundType] = description + "\n" + bg.backgroundDescription
				} else {
					backgrounds[bg.backgroundType] = bg.backgroundDescription
				}
			}
		}
		return backgrounds
	}
	
	func backgroundsArray() -> [RBackground] {
		var backgrounds = [RBackground]()
		
		for (key, value) in self.backgroundsDictionary() {
			if value != "" {
				let rBackground = RBackground()
				rBackground.backgroundType = key
				rBackground.backgroundDescription = value
				backgrounds.append(rBackground)
			}
		}
		return backgrounds
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
}
