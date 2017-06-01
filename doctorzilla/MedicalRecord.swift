//
//  MedicalRecord.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/23/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire

class MedicalRecord {
	
	private var _medrecordURL: String!
	private var _recordId: Int!
	private var _document: String!
	private var _name: String!
	private var _lastName: String!
	private var _birthday: String!
	private var _firstConsultation: String!
	private var _occupation: String!
	private var _email: String!
	private var _phone: String!
	private var _cellphone: String!
	private var _insurance: String!
	private var _referredBy: String!
	private var _height: Int!
	private var _weight: Int!
	private var _pressure_d: String!
	private var _pressure_s: String!
	private var _backgrounds: [String: String] = ["Familiares":" ", "Alergias":"", "Diábetes":"", "Asma":"", "Cardiopatías":"", "Medicamentos":"", "Quirúrgicos":"", "Otros":""]
	
	private var _consultations = [Consultation]()
	
	var recordId: Int {
		if _recordId == nil {
			_recordId = 0
		}
		return _recordId
	}
	
	var document: String {
		if _document == nil {
			_document = ""
		}
		return _document
	}
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		return _name
	}
	
	var lastName: String {
		if _lastName == nil {
			_lastName = ""
		}
		return _lastName
	}
	
	var birthday: String {
		if _birthday == nil {
			_birthday = ""
		}
		return _birthday
	}
	
	var firstConsultation: String {
		if _firstConsultation == nil {
			_firstConsultation = ""
		}
		return _firstConsultation
	}
	
	var occupation: String {
		if _occupation == nil {
			_occupation = ""
		}
		return _occupation
	}
	
	var email: String {
		if _email == nil {
			_email = ""
		}
		return _email
	}
	
	var phone: String {
		if _phone == nil {
			_phone = ""
		}
		return _phone
	}
	
	var cellphone: String {
		if _cellphone == nil {
			_cellphone = ""
		}
		return _cellphone
	}
	
	var insurance: String {
		if _insurance == nil {
			_insurance = ""
		}
		return _insurance
	}
	
	var referredBy: String {
		if _referredBy == nil {
			_referredBy = ""
		}
		return _referredBy
	}
	
	var height: Int {
		if _height == nil {
			_height = 0
		}
		return _height
	}
	
	var weight: Int {
		if _weight == nil {
			_weight = 0
		}
		return _weight
	}
	
	var pressure_d: String {
		if _pressure_d == nil {
			_pressure_d = ""
		}
		return _pressure_d
	}
	
	var pressure_s: String {
		if _pressure_s == nil {
			_pressure_s = ""
		}
		return _pressure_s
	}
	
	var backgrounds: [String: String] {
		return _backgrounds
	}
	
	var consultations: [Consultation] {
		return _consultations
	}
	
	init(recordId: Int, document: String, lastName: String) {
		
		self._recordId = recordId
		self._document = document
		self._lastName = lastName
		
		self._medrecordURL = "\(URL_BASE)\(URL_MEDICAL_RECORDS)\(self.recordId)/"
	}
	
	func downloadRecordDetails(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(_medrecordURL, method: .get, headers: headers).responseJSON { (response) in
			
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				
				// NAME
				if let name = dict["name"] as? String {
					self._name = name
				}
				
				// BIRTHDAY
				if let birthday = dict["birthday"] as? String {
					self._birthday = birthday
				}
				
				// FIRST CONSULTATION DATE
				if let firstConsultation = dict["first_consultation_date"] as? String {
					self._firstConsultation = firstConsultation
				}
				
				// OCCUPATION
				if let occupationDict = dict["occupation"] as? Dictionary<String, AnyObject> {
					if let occupation = occupationDict["name"] as? String {
						self._occupation = occupation
					}
				}
				
				// EMAIL
				if let email = dict["email"] as? String {
					self._email = email
				}
				
				// PHONE
				if let phone = dict["phone_number"] as? String {
					self._phone = phone
				}
				
				// CELLPHONE
				if let cellphone = dict["cellphone_number"] as? String {
					self._cellphone = cellphone
				}
				
				// INSURANCE
				if let insuranceDict = dict["insurance"] as? Dictionary<String, AnyObject> {
					if let insurance = insuranceDict["name"] as? String {
						self._insurance = insurance
					}
				}
				
				// REFERRED BY
				if let referredBy = dict["referred_by"] as? String {
					self._referredBy = referredBy
				}
				
				// PHYSIC DATA
				if let physicData = dict["physic_data"] as? Dictionary<String, AnyObject> {
					// Height
					if let height = physicData["height"] as? Int {
						self._height = height
					}
					// Weight
					if let weight = physicData["weight"] as? Int {
						self._weight = weight
					}
					// Pressure D
					if let pressure_d = physicData["pressure_d"] as? String {
						self._pressure_d = pressure_d
					}
					// Pressure S
					if let pressure_s = physicData["pressure_s"] as? String {
						self._pressure_s = pressure_s
					}
				}
				
				// BACKGROUNDS
				if let backgrounds = dict["backgrounds"] as? Dictionary<String, [String]> {
					
					if let family = backgrounds["Familiares"]{
						self._backgrounds["Familiares"] = self.parseDescriptions(descriptions: family)
					}
					if let allergy = backgrounds["Alergias"]{
						self._backgrounds["Alergias"] = self.parseDescriptions(descriptions: allergy)
					}
					if let diabetes = backgrounds["Diábetes"]{
						self._backgrounds["Diábetes"] = self.parseDescriptions(descriptions: diabetes)
					}
					if let asthma = backgrounds["Asma"]{
						self._backgrounds["Asma"] = self.parseDescriptions(descriptions: asthma)
					}
					if let heart = backgrounds["Cardiopatías"]{
						self._backgrounds["Cardiopatías"] = self.parseDescriptions(descriptions: heart)
					}
					if let medicine = backgrounds["Medicamentos"]{
						self._backgrounds["Medicamentos"] = self.parseDescriptions(descriptions: medicine)
					}
					if let surgical = backgrounds["Quirúrgicos"]{
						self._backgrounds["Quirúrgicos"] = self.parseDescriptions(descriptions: surgical)
					}
					if let other = backgrounds["Otros"]{
						self._backgrounds["Otros"] = self.parseDescriptions(descriptions: other)
					}
			
				}
				
			}
			completed()
		}
		
	}
	
	func downloadConsultations(completed: @escaping DownloadComplete) {
		
		let consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"record": recordId
		]
		
		Alamofire.request(consultationURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
	
			if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
				
				self._consultations.removeAll()
				
				for cnslttn in dict {
					
					var id = 0
					var date = ""
					var reason = ""
					
					// ID
					if let cnslttnId = cnslttn["id"] as? Int {
						id = cnslttnId
					}
					
					// DATE
					if let cnslttnDate = cnslttn["created_at"] as? String {
						date = cnslttnDate
					}
					
					// REASON
					if let cnslttnReason = cnslttn["reason"] as? Dictionary<String, AnyObject> {
						if let reasonDesc = cnslttnReason["description"] as? String {
							reason = reasonDesc
						}
					}
					
					self._consultations.append(Consultation(consultationId: id, date: date, reason: reason))
				}

			}
			completed()
		}
	}
	
	func parseDescriptions(descriptions: [String]) -> String {
		var bgDescription = ""
		
		for description in descriptions {
			bgDescription += "\(description)\n"
		}
		
		return bgDescription
	}
	
	func age() -> Int {
		var age = 0

		let dateFormatter = DateFormatter()
		
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		if let birthday = self._birthday {
			if let date = dateFormatter.date(from: birthday) {
				let components = Calendar.current.dateComponents([.year], from: date, to: Date())
				
				age = components.year!
			}
		}
		
		return age
	}
	
	func parsedFirstConsultationDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		if let firstConsultation = self._firstConsultation {
			if let date: Date = dateFormatterGet.date(from: firstConsultation){
				parsedDate = dateFormatterResult.string(from: date)
			}
		}
		
		return parsedDate
	}
	
	func parsedBirthdayDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		if let birthday = self._birthday {
			if let date: Date = dateFormatterGet.date(from: birthday) {
				parsedDate = dateFormatterResult.string(from: date)
			}
		}

		return parsedDate
	}
	
	func IMC() -> Double {
		if self.weight != 0 && self.height != 0 {
			let imc = ((Double(self.weight))/(pow(Double(self.height)/100, 2)) * 100).rounded() / 100
			return imc
		} else {
			return 0.0
		}
	}

}
