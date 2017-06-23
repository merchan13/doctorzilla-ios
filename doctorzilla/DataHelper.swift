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

class DataHelper {
	let realm = try! Realm()
	
	/// Descargar foto de perfil Historia Medicas
	//
	func downloadProfilePicture(rec: RMedicalRecord, completed: @escaping DownloadComplete) {
		
		Alamofire.request(rec.profilePicURL).responseImage { response in
			if let image = response.result.value {
				let size = CGSize(width: 100.0, height: 100.0)
				let resizedImage = image.af_imageAspectScaled(toFit: size)
				let circularImage = resizedImage.af_imageRoundedIntoCircle()
				let imageData:NSData = UIImageJPEGRepresentation(circularImage, 0)! as NSData
				
				NSLog("Data length: %u KB",(imageData.length/1024));
				
				try! self.realm.write {
					rec.profilePic = imageData
				}
			}
			completed()
		}
	}
	
	/// Descargar Historia Medicas
	//
	func downloadRecords(rUser: RUser, completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let dict = response.result.value as? [Dictionary<String, AnyObject>]{
				try! self.realm.write {
					for recordDict in dict {
						let rMedRecord = self.parseMedicalRecord(recordDict: recordDict)
						
						rMedRecord.user = rUser
						self.realm.add(rMedRecord, update: true)
					}
				}
			}
			completed()
		}
	}
	
	/// Descargar Consultas
	//
	func downloadConsultations(completed: @escaping DownloadComplete) {
		let consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let records = realm.objects(RMedicalRecord.self).sorted(byKeyPath: "id")
		
		for record in records {
			let parameters: Parameters = [
				"record": record.id
			]
			
			Alamofire.request(consultationURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
				if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
					
					try! self.realm.write {
						for consultationDict in dict {
							let rConsultation = self.parseConsultation(consultationDict: consultationDict)
							
							self.realm.add(rConsultation, update: true)
							record.consultations.append(rConsultation)
						}
					}
				}
				if record.id == records.last?.id {
					completed()
				}
			}
		}
	}
	
	/// Descargar Antecedentes
	//
	func downloadBackgrounds(completed: @escaping DownloadComplete) {
		let backgroundURL = "\(URL_BASE)\(URL_BACKGROUNDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let consultations = realm.objects(RConsultation.self)
		
		for consultation in consultations {
			let parameters: Parameters = [
				"consultation": consultation.id
			]
			
			Alamofire.request(backgroundURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
				if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
					
					try! self.realm.write {
						for backgroundDict in dict {
							let rBackground = RBackground()
							if let bgId = backgroundDict["id"] as? Int {
								rBackground.id = bgId
							}
							if let bgConsultationId = backgroundDict["consultation_id"] as? Int {
								rBackground.consultationId = bgConsultationId
							}
							if let bgType = backgroundDict["background_type"] as? String {
								rBackground.backgroundType = bgType
							}
							if let bgDescription = backgroundDict["description"] as? String {
								rBackground.backgroundDescription = bgDescription
							}
							if let bgLastUpdate = backgroundDict["updated_at"] as? String {
								rBackground.lastUpdate = bgLastUpdate.dateFromISO8601!
							}
							
							self.realm.add(rBackground, update: true)
							consultation.backgrounds.append(rBackground)
						}
					}
				}
			}
		}
		completed()
	}
	
	/// Descargar Examenes Fisicos
	//
	func downloadPhysicalExams(completed: @escaping DownloadComplete) {
		let PEURL = "\(URL_BASE)\(URL_PHYSICAL_EXAMS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let consultations = realm.objects(RConsultation.self)
		
		for consultation in consultations {
			let parameters: Parameters = [
				"consultation": consultation.id
			]
			
			Alamofire.request(PEURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
				
				if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
					try! self.realm.write {
						for PEDict in dict {
							let rPE = RPhysicalExam()
							if let PEId = PEDict["id"] as? Int {
								rPE.id = PEId
							}
							if let PEConsultationId = PEDict["consultation_id"] as? Int {
								rPE.consultationId = PEConsultationId
							}
							if let PEType = PEDict["exam_type"] as? String {
								rPE.examType = PEType
							}
							if let PEObservation = PEDict["observation"] as? String {
								rPE.observation = PEObservation
							}
							if let PELastUpdate = PEDict["updated_at"] as? String {
								rPE.lastUpdate = PELastUpdate.dateFromISO8601!
							}
							
							self.realm.add(rPE, update: true)
							consultation.physicalExams.append(rPE)
						}
					}
				}
			}
		}
		completed()
	}
	
	/// Descargar Planes
	//
	func downloadPlans(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let consultations = realm.objects(RConsultation.self)
		
		for consultation in consultations {
			
			if let id = consultation.plan?.id {
				let planURL = "\(URL_BASE)\(URL_PLANS)\(id)"
				
				Alamofire.request(planURL, method: .get, headers: headers).responseJSON { (response) in
					
					if let planDict = response.result.value as? Dictionary<String, AnyObject> {
						try! self.realm.write {
							if let planConsultationId = planDict["consultation_id"] as? Int {
								consultation.plan!.consultationId = planConsultationId
							}
							if let planDescription = planDict["description"] as? String {
								consultation.plan!.planDescription = planDescription
							}
							if let planEmergency = planDict["emergency"] as? Bool {
								consultation.plan!.emergency = planEmergency
							}
							
							if let planLastUpdate = planDict["updated_at"] as? String {
								consultation.plan!.lastUpdate = planLastUpdate.dateFromISO8601!
							}
						}
					}
				}
			}
		}
		completed()
	}
	
	/// Descargar Profesiones
	//
	func downloadOccupations(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_OCCUPATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let occupationDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for occupation in occupationDictionary {
						let rOccupation = ROccupation()
						if let occupationId = occupation["id"] as? Int {
							rOccupation.id = occupationId
						}
						if let occupationName = occupation["name"] as? String {
							rOccupation.name = occupationName
						}
						
						self.realm.add(rOccupation, update: true)
					}
				}
			}
			completed()
		}
	}
	
	/// Descargar Seguros
	//
	func downloadInsurances(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_INSURANCES)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let insuranceDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for insurance in insuranceDictionary {
						let rInsurance = RInsurance()
						if let insuranceId = insurance["id"] as? Int {
							rInsurance.id = insuranceId
						}
						if let insuranceName = insurance["name"] as? String {
							rInsurance.name = insuranceName
						}
						
						self.realm.add(rInsurance, update: true)
					}
				}
			}
			completed()
		}
	}
	
	/// Descargar Diagnosticos
	//
	func downloadDiagnostics(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_DIAGNOSTICS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let diagnosticDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for diagnostic in diagnosticDictionary {
						let rDiagnostic = RDiagnostic()
						if let diagnosticId = diagnostic["id"] as? Int {
							rDiagnostic.id = diagnosticId
						}
						if let diagnosticDescription = diagnostic["description"] as? String {
							rDiagnostic.diagnosticDescription = diagnosticDescription
						}
						
						self.realm.add(rDiagnostic, update: true)
					}
				}
			}
			completed()
		}
	}
	
	/// Descargar Motivos de Consulta
	//
	func downloadReasons(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_REASONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let reasonDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for reason in reasonDictionary {
						let rReason = RReason()
						if let reasonId = reason["id"] as? Int {
							rReason.id = reasonId
						}
						if let reasonDescription = reason["description"] as? String {
							rReason.reasonDescription = reasonDescription
						}
						
						self.realm.add(rReason, update: true)
					}
				}
			}
			completed()
		}
	}
	
	/// Actualizar Historia Medica (Servidor)
	//
	func updateRecord(record: RMedicalRecord, completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		var occupation = ""
		var insurance = ""
		
		if let occupationRLM = record.occupation {
			occupation = "\(occupationRLM.id)"
		}
		
		if let insuranceRLM = record.insurance {
			insurance = "\(insuranceRLM.id)"
		}
		
		let parameters: Parameters = [
			"medical_record": [
				"name": record.name,
				"last_name": record.lastName,
				"occupation_id": occupation,
				"birthday": record.birthday,
				"gender": record.gender,
				"phone_number": record.phone,
				"cellphone_number": record.cellphone,
				"email": record.email,
				"address": record.address,
				"referred_by": record.referredBy,
				"insurance_id": insurance
			]
		]
		
		Alamofire.request("\(URL_BASE)\(URL_MEDICAL_RECORDS)\(record.id)", method: .put, parameters: parameters, headers: headers).responseJSON { response in
			//print(response.response?.statusCode)
			completed()
		}
	}
	
	/// Actualizar Consulta (Servidor)
	//
	func updateConsultation(consultation: RConsultation, completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		var reason = ""
		var diagnostic = ""
		
		if let reasonRLM = consultation.reason {
			reason = "\(reasonRLM.id)"
		}
		
		if let diagnosticRLM = consultation.diagnostic {
			diagnostic = "\(diagnosticRLM.id)"
		}
		
		let parameters: Parameters = [
			"consultation": [
				"affliction": consultation.affliction,
				"diagnostic_id": diagnostic,
				"evolution": consultation.evolution,
				"height": "\(consultation.height)",
				"note": consultation.note,
				"pressure_s": consultation.pressure_s,
				"pressure_d": consultation.pressure_d,
				"reason_id": reason,
				"weight": "\(consultation.weight)"
			]
		]
		
		Alamofire.request("\(URL_BASE)\(URL_CONSULTATIONS)\(consultation.id)", method: .put, parameters: parameters, headers: headers).responseJSON { response in
			//print(response.response?.statusCode)
			completed()
		}
	}
	
	/// Parse MedicalRecrod Dictionary into Realm Object - [NOTA: al invocar esta funcion, se debe rodear de un bloque de escritura de Realm]
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
				} else {
					let rOccupation = ROccupation()
					if let occupationId = occupationDict["id"] as? Int {
						rOccupation.id = occupationId
					}
					if let occupationName = occupationDict["name"] as? String {
						rOccupation.name = occupationName
					}
					
					realm.add(rOccupation, update: true)
					rMedRecord.occupation = rOccupation
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
				} else {
					let rInsurance = RInsurance()
					if let insuranceId = insuranceDict["id"] as? Int {
						rInsurance.id = insuranceId
					}
					if let insuranceName = insuranceDict["name"] as? String {
						rInsurance.name = insuranceName
					}
					
					realm.add(rInsurance, update: true)
					rMedRecord.insurance = rInsurance
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
		
		if let profilePictureURL = recordDict["profile_picture"] as? String {
			rMedRecord.profilePicURL = profilePictureURL
		}
	
		return rMedRecord
	}
	
	/// Parse Consultation Dictionary into Realm Object - [NOTA: al invocar esta funcion, se debe rodear de un bloque de escritura de Realm]
	//
	func parseConsultation(consultationDict: Dictionary<String,AnyObject>) -> RConsultation {
		let rConsultation = RConsultation()
		// ID
		if let id = consultationDict["id"] as? Int {
			rConsultation.id = id
		}
		// MEDICAL RECORD ID
		if let recordId = consultationDict["medical_record_id"] as? Int {
			rConsultation.recordId = recordId
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
				if let diagnosticRLM = self.realm.object(ofType: RDiagnostic.self, forPrimaryKey: diagnostic) {
					rConsultation.diagnostic = diagnosticRLM
				} else {
					let rDiagnostic = RDiagnostic()
					if let diagnosticId = diagnosticDict["id"] as? Int {
						rDiagnostic.id = diagnosticId
					}
					if let diagnosticDescription = diagnosticDict["description"] as? String {
						rDiagnostic.diagnosticDescription = diagnosticDescription
					}
					
					self.realm.add(rDiagnostic, update: true)
					rConsultation.diagnostic = rDiagnostic
				}
			}
		}
		// REASON
		if let reasonDict = consultationDict["reason"] as? Dictionary<String, AnyObject> {
			if let reason = reasonDict["id"] as? Int {
				if let reasonRLM = self.realm.object(ofType: RReason.self, forPrimaryKey: reason) {
					rConsultation.reason = reasonRLM
				} else {
					let rReason = RReason()
					if let reasonId = reasonDict["id"] as? Int {
						rReason.id = reasonId
					}
					if let reasonDescription = reasonDict["description"] as? String {
						rReason.reasonDescription = reasonDescription
					}
					
					self.realm.add(rReason, update: true)
					rConsultation.reason = rReason
				}
			}
		}
		// PLAN
		if let planDict = consultationDict["plan"] as? Dictionary<String, AnyObject> {
			if let plan = planDict["id"] as? Int {
				if let planRLM = self.realm.object(ofType: RPlan.self, forPrimaryKey: plan) {
					rConsultation.plan = planRLM
				} else {
					let rPlan = RPlan()
					if let planId = planDict["id"] as? Int {
						rPlan.id = planId
					}
					
					self.realm.add(rPlan, update: true)
					rConsultation.plan = rPlan
				}
			}
		}
	
		return rConsultation
	}
}

