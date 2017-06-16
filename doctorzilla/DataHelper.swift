//
//  DataHelper.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/5/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

let realm = try! Realm()

/// Download Occupations
//
func dowloadOccupations(completed: @escaping DownloadComplete) {
	let url = "\(URL_BASE)\(URL_OCCUPATIONS)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
		if let occupationDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
			
			try! realm.write {
				for occupation in occupationDictionary {
					let rOccupation = ROccupation()
					if let occupationId = occupation["id"] as? Int {
						rOccupation.id = occupationId
					}
					if let occupationName = occupation["name"] as? String {
						rOccupation.name = occupationName
					}
					
					realm.add(rOccupation, update: true)
				}
			}
		}
		completed()
	}
}

/// Download Insurances
//
func dowloadInsurances(completed: @escaping DownloadComplete) {
	let url = "\(URL_BASE)\(URL_INSURANCES)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
		if let insuranceDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
			
			try! realm.write {
				for insurance in insuranceDictionary {
					let rInsurance = RInsurance()
					if let insuranceId = insurance["id"] as? Int {
						rInsurance.id = insuranceId
					}
					if let insuranceName = insurance["name"] as? String {
						rInsurance.name = insuranceName
					}
					
					realm.add(rInsurance, update: true)
				}
			}
		}
		completed()
	}
}

/// Download Diagnostics
//
func dowloadDiagnostics(completed: @escaping DownloadComplete) {
	let url = "\(URL_BASE)\(URL_DIAGNOSTICS)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
		if let diagnosticDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
			
			try! realm.write {
				for diagnostic in diagnosticDictionary {
					let rDiagnostic = RDiagnostic()
					if let diagnosticId = diagnostic["id"] as? Int {
						rDiagnostic.id = diagnosticId
					}
					if let diagnosticDescription = diagnostic["description"] as? String {
						rDiagnostic.diagnosticDescription = diagnosticDescription
					}
					
					realm.add(rDiagnostic, update: true)
				}
			}
		}
		completed()
	}
}

/// Download Reasons
//
func dowloadReasons(completed: @escaping DownloadComplete) {
	let url = "\(URL_BASE)\(URL_REASONS)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
		if let reasonDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
			
			try! realm.write {
				for reason in reasonDictionary {
					let rReason = RReason()
					if let reasonId = reason["id"] as? Int {
						rReason.id = reasonId
					}
					if let reasonDescription = reason["description"] as? String {
						rReason.reasonDescription = reasonDescription
					}
					
					realm.add(rReason, update: true)
				}
			}
		}
		completed()
	}
}

/// Download Records
//
func dowloadRecords(rUser: RUser, completed: @escaping DownloadComplete) {
	let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
		if let dict = response.result.value as? [Dictionary<String, AnyObject>]{
			try! realm.write {
				for recordDict in dict {
					let rMedRecord = parseMedicalRecord(recordDict: recordDict)
					rMedRecord.user = rUser
					realm.add(rMedRecord, update: true)
				}
			}
		}
		completed()
	}
}

/// Download Consultations
//
func downloadConsultations(completed: @escaping DownloadComplete) {
	let consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)"
	
	let headers: HTTPHeaders = [
		"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
	]
	
	let records = realm.objects(RMedicalRecord.self)
	
	for record in records {
		let parameters: Parameters = [
			"record": record.id
		]
		
		Alamofire.request(consultationURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
			if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
				try! realm.write {
					
					//record.consultations.removeAll()
					
					for consultationDict in dict {
						let rConsultation = parseConsultation(consultationDict: consultationDict)
						realm.add(rConsultation, update: true)
						record.consultations.append(rConsultation)
					}
				}
			}
		}
	}
	completed()
}

/// Parse MedicalRecrod Dictionary into Realm Object
//
func parseMedicalRecord(recordDict: Dictionary<String, AnyObject>) -> RMedicalRecord {
	let rMedRecord = RMedicalRecord()
	// ID
	if let recordId = recordDict["id"] as? Int {
		rMedRecord.id = recordId
	}
	// DOCUMENT
	if let documentType = recordDict["document_type"] as? String {
		if let document = recordDict["document"] as? String {
			rMedRecord.document = "\(documentType)-\(document)"
		}
	}
	// NAME
	if let name = recordDict["name"] as? String {
		rMedRecord.name = name
	}
	// LAST NAME
	if let lastName = recordDict["last_name"] as? String {
		rMedRecord.lastName = lastName
	}
	// BIRTHDAY
	if let birthday = recordDict["birthday"] as? String {
		rMedRecord.birthday = birthday
	}
	// FIRST CONSULTATION
	if let firstConsultation = recordDict["first_consultation_date"] as? String {
		rMedRecord.firstConsultation = firstConsultation
	}
	// OCCUPATION
	if let occupationDict = recordDict["occupation"] as? Dictionary<String, AnyObject> {
		if let occupation = occupationDict["id"] as? Int {
			if let occupationRLM = realm.object(ofType: ROccupation.self, forPrimaryKey: occupation) {
				rMedRecord.occupation = occupationRLM
			}
		}
	}
	// EMAIL
	if let email = recordDict["email"] as? String {
		rMedRecord.email = email
	}
	// PHONE
	if let phone = recordDict["phone_number"] as? String {
		rMedRecord.phone = phone
	}
	// CELLPHONE
	if let cellphone = recordDict["cellphone_number"] as? String {
		rMedRecord.cellphone = cellphone
	}
	// ADDRESS
	if let address = recordDict["address"] as? String {
		rMedRecord.address = address
	}
	// GENDER
	if let gender = recordDict["gender"] as? String {
		rMedRecord.gender = gender
	}
	// INSURANCE
	if let insuranceDict = recordDict["insurance"] as? Dictionary<String, AnyObject> {
		if let insurance = insuranceDict["id"] as? Int {
			if let insuranceRLM = realm.object(ofType: RInsurance.self, forPrimaryKey: insurance) {
				rMedRecord.insurance = insuranceRLM
			}
		}
	}
	// REFERRED BY
	if let referredBy = recordDict["referred_by"] as? String {
		rMedRecord.referredBy = referredBy
	}
	// LAST UPDATE DATE
	if let lastUpdate = recordDict["updated_at"] as? String {
		rMedRecord.lastUpdate = lastUpdate.dateFromISO8601!
	}
	// PHYSIC DATA
	if let physicData = recordDict["physic_data"] as? Dictionary<String, AnyObject> {
		// Height
		if let height = physicData["height"] as? Int {
			rMedRecord.height = height
		}
		// Weight
		if let weight = physicData["weight"] as? Int {
			rMedRecord.weight = weight
		}
		// Pressure D
		if let pressure_d = physicData["pressure_d"] as? String {
			rMedRecord.pressure_d = pressure_d
		}
		// Pressure S
		if let pressure_s = physicData["pressure_s"] as? String {
			rMedRecord.pressure_s = pressure_s
		}
	}
	return rMedRecord
}

/// Parse Consultation Dictionary into Realm Object
//
func parseConsultation(consultationDict: Dictionary<String,AnyObject>) -> RConsultation {
	let rConsultation = RConsultation()
	// ID
	if let id = consultationDict["id"] as? Int {
		rConsultation.id = id
	}
	// DATE
	if let date = consultationDict["created_at"] as? String {
		rConsultation.date = date
	}
	// AFFLICTION
	if let affliction = consultationDict["affliction"] as? String {
		rConsultation.affliction = affliction
	}
	// EVOLUTION
	if let evolution = consultationDict["evolution"] as? String {
		rConsultation.evolution = evolution
	}
	// HEIGHT
	if let height = consultationDict["height"] as? Int {
		rConsultation.height = height
	}
	// WEIGHT
	if let weight = consultationDict["weight"] as? Int {
		rConsultation.weight = weight
	}
	// PRESSURE_S
	if let pressure_s = consultationDict["pressure_s"] as? String {
		rConsultation.pressure_s = pressure_s
	}
	// PRESSURE_D
	if let pressure_d = consultationDict["pressure_d"] as? String {
		rConsultation.pressure_d = pressure_d
	}
	// NOTE
	if let note = consultationDict["note"] as? String {
		rConsultation.note = note
	}
	// LAST UPDATE DATE
	if let lastUpdate = consultationDict["updated_at"] as? String {
		rConsultation.lastUpdate = lastUpdate.dateFromISO8601!
	}
	// DIAGNOSTIC
	if let diagnosticDict = consultationDict["diagnostic"] as?  Dictionary<String, AnyObject> {
		if let diagnostic = diagnosticDict["id"] as? Int {
			if let diagnosticRLM = realm.object(ofType: RDiagnostic.self, forPrimaryKey: diagnostic) {
				rConsultation.diagnostic = diagnosticRLM
			}
		}
	}
	// REASON
	if let reasonDict = consultationDict["reason"] as? Dictionary<String, AnyObject> {
		if let reason = reasonDict["id"] as? Int {
			if let reasonRLM = realm.object(ofType: RReason.self, forPrimaryKey: reason) {
				rConsultation.reason = reasonRLM
			}
		}
	}
	return rConsultation
}

/*
*
*
// BACKGROUNDS
if let backgrounds = consultationDict["backgrounds"] as? [Dictionary<String, AnyObject>] {
	rConsultation.backgrounds.removeAll()
	try! realm.write {
		for bg in backgrounds {
			let rBackground = RBackground()
			rBackground.id = bg["id"] as! Int
			rBackground.backgroundType = bg["background_type"] as! String
			rBackground.backgroundDescription = bg["description"] as! String
			realm.add(rBackground, update: true)
			
			rConsultation.backgrounds.append(rBackground)
		}
	}
}
// PHYSICAL EXAMS
if let physicalExams = consultationDict["physical_exams"] as? [Dictionary<String, AnyObject>] {
	rConsultation.physicalExams.removeAll()
	try! realm.write {
		for pe in physicalExams {
			let rPhysicalExam = RPhysicalExam()
			rPhysicalExam.id = pe["id"] as! Int
			rPhysicalExam.examType = pe["exam_type"] as! String
			rPhysicalExam.observation = pe["observation"] as! String
			realm.add(rPhysicalExam, update: true)
			
			rConsultation.physicalExams.append(rPhysicalExam)
		}
	}
}
*
*
*/

