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
				
				let imageData:NSData = UIImageJPEGRepresentation(circularImage, 0.30)! as NSData
				
				NSLog("Data length: %u KB",(imageData.length/1024));
				
				try! self.realm.write {
					
					rec.profilePic = imageData
				}
			}
			
			completed()
		}
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
	
	
	/// Descargar Historia Medica por Id
	//
	func downloadRecord(recordId: Int, completed: @escaping DownloadComplete) {
		
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)\(recordId)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			
			if let recordDict = response.result.value as? Dictionary<String, AnyObject> {
				
				try! self.realm.write {
					
					let rMedRecord = self.parseMedicalRecord(recordDict: recordDict)
					
					rMedRecord.user = self.realm.objects(RUser.self).first
					
					self.realm.add(rMedRecord, update: true)
				}
			}
			
			completed()
		}
	}
	
	
	/// Descargar Consultas de una Historia Medica
	//
	func downloadConsultations(recordId: Int, completed: @escaping DownloadComplete) {
		
		let consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let record = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: recordId)!
		
		let parameters: Parameters = [
			"record": recordId
		]
		
		Alamofire.request(consultationURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
			
			if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
				
				try! self.realm.write {
					
					record.consultations.removeAll()
					
					for consultationDict in dict {
						
						let rConsultation = self.parseConsultation(consultationDict: consultationDict)
						
						self.realm.add(rConsultation, update: true)
						
						record.consultations.append(rConsultation)
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
		
		if let reasonRLM = consultation.reason {
			reason = "\(reasonRLM.id)"
		}
		
		let parameters: Parameters = [
			"consultation": [
				"affliction": consultation.affliction,
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
	
	
	/// Crear Consulta Médica (Servidor)
	//
	func createConsultation(consultation: RConsultation, completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"consultation": [
				"note": consultation.note
			],
			"record": consultation.recordId
		]
		
		Alamofire.request("\(URL_BASE)\(URL_CONSULTATIONS)", method: .post, parameters: parameters, headers: headers).responseJSON { response in
			
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
		// HV
		if let recordHV = recordDict["old_record_number"] as? String {
			rMedRecord.hv = recordHV
		}
		// ADDRESS
		if let address = recordDict["address"] as? String {
			rMedRecord.address = address
		}
		// ATACHMENTS
		if let attachmentsDict = recordDict["attachments"] as? [Dictionary<String, AnyObject>] {
			
			rMedRecord.attachments.removeAll()
			
			for attachDict in attachmentsDict {
				if let attachmentId = attachDict["id"] as? Int {
					if let attachmentRLM = realm.object(ofType: RAttachment.self, forPrimaryKey: attachmentId) {
						rMedRecord.attachments.append(attachmentRLM)
					} else {
						let rAttachment = RAttachment()
						
						rAttachment.id = attachmentId
						
						if let attachmentRecordId = attachDict["medical_record_id"] as? Int {
							rAttachment.recordId = attachmentRecordId
						}
						if let attachmentDescription = attachDict["description"] as? String {
							rAttachment.attachmentDescription = attachmentDescription
						}
						if let attachmentDate = attachDict["updated_at"] as? String {
							rAttachment.date = attachmentDate
						}
						
						realm.add(rAttachment, update: true)
						rMedRecord.attachments.append(rAttachment)
					}
				}
			}
		}
		// BACKGROUNDS
		if let bgsDict = recordDict["backgrounds"] as? [Dictionary<String, AnyObject>] {
			
			for oldBg in rMedRecord.backgrounds {
				if let toDelete = realm.object(ofType: RBackground.self, forPrimaryKey: oldBg.id) {
					self.realm.delete(toDelete)
				}
			}
			
			rMedRecord.backgrounds.removeAll()
			
			for bgDict in bgsDict {
				if let bgId = bgDict["id"] as? Int {
					if let bgRLM = realm.object(ofType: RBackground.self, forPrimaryKey: bgId) {
						rMedRecord.backgrounds.append(bgRLM)
					} else {
						let rBg = RBackground()
						
						rBg.id = bgId
						
						if let bgRecordId = bgDict["medical_record_id"] as? Int {
							rBg.recordId = bgRecordId
						}
						if let bgType = bgDict["background_type"] as? String {
							rBg.backgroundType = bgType
						}
						if let bgDescription = bgDict["description"] as? String {
							rBg.backgroundDescription = bgDescription
						}
						if let bgLastUpdate = bgDict["updated_at"] as? String {
							rBg.lastUpdate = bgLastUpdate.dateFromISO8601!
						}
						
						realm.add(rBg, update: true)
						rMedRecord.backgrounds.append(rBg)
					}
				}
			}
		}
		// BIRTHDAY
		if let birthday = recordDict["birthday"] as? String {
			rMedRecord.birthday = birthday
		}
		// CELLPHONE
		if let cellphone = recordDict["cellphone_number"] as? String {
			rMedRecord.cellphone = cellphone
		}
		// DOCUMENT
		if let documentType = recordDict["document_type"] as? String {
			if let document = recordDict["document"] as? String {
				rMedRecord.document = "\(documentType)-\(document)"
			}
		}
		// EMAIL
		if let email = recordDict["email"] as? String {
			rMedRecord.email = email
		}
		// FIRST CONSULTATION
		if let firstConsultation = recordDict["first_consultation_date"] as? String {
			rMedRecord.firstConsultation = firstConsultation
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
		// LAST NAME
		if let lastName = recordDict["last_name"] as? String {
			rMedRecord.lastName = lastName
		}
		// NAME
		if let name = recordDict["name"] as? String {
			rMedRecord.name = name
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
		// PHONE
		if let phone = recordDict["phone_number"] as? String {
			rMedRecord.phone = phone
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
		// PROFILE PICTURE URL
		if let profilePictureURL = recordDict["profile_picture"] as? String {
			rMedRecord.profilePicURL = profilePictureURL
		}
		// REFERRED BY
		if let referredBy = recordDict["referred_by"] as? String {
			rMedRecord.referredBy = referredBy
		}
		// REPORTS
		if let reportsDict = recordDict["reports"] as? [Dictionary<String, AnyObject>] {
			
			rMedRecord.reports.removeAll()
			
			for reportDict in reportsDict {
				if let reportId = reportDict["id"] as? Int {
					if let reportRLM = realm.object(ofType: RReport.self, forPrimaryKey: reportId) {
						rMedRecord.reports.append(reportRLM)
					} else {
						let rReport = RReport()
						
						rReport.id = reportId
						
						if let reportRecordId = reportDict["medical_record_id"] as? Int {
							rReport.recordId = reportRecordId
						}
						if let reportType = reportDict["report_type"] as? String {
							rReport.reportType = reportType
						}
						if let reportDescription = reportDict["description"] as? String {
							rReport.reportDescription = reportDescription
						}
						if let reportDate = reportDict["updated_at"] as? String {
							rReport.date = reportDate
						}
						
						realm.add(rReport, update: true)
						rMedRecord.reports.append(rReport)
					}
				}
			}
		}
		// UPDATED AT
		if let lastUpdate = recordDict["updated_at"] as? String {
			rMedRecord.lastUpdate = lastUpdate.dateFromISO8601!
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
		// AFFLICTION
		if let affliction = consultationDict["affliction"] as? String {
			rConsultation.affliction = affliction
		}
		// DATE
		if let date = consultationDict["created_at"] as? String {
			rConsultation.date = date
		}
		// DIAGNOSTICS
		if let diagnostics = consultationDict["diagnostics"] as? [Dictionary<String, AnyObject>]{
			rConsultation.diagnostics.removeAll()
			
			for diagnosticDict in diagnostics {
				let rDiagnostic = RDiagnostic()
				if let diagnosticId = diagnosticDict["id"] as? Int {
					rDiagnostic.id = diagnosticId
				}
				if let diagnosticDescription = diagnosticDict["description"] as? String {
					rDiagnostic.diagnosticDescription = diagnosticDescription
				}
				if let diagnosticLastUpdate = diagnosticDict["added_at"] as? String {
					rDiagnostic.lastUpdate = diagnosticLastUpdate.dateFromISO8601!
				}
				
				self.realm.add(rDiagnostic, update: true)
				rConsultation.diagnostics.append(rDiagnostic)
			}
		}
		// EVOLUTION
		if let evolution = consultationDict["evolution"] as? String {
			rConsultation.evolution = evolution
		}
		// HEIGHT
		if let height = consultationDict["height"] as? Int {
			rConsultation.height = height
		}
		// MEDICAL RECORD ID
		if let recordId = consultationDict["medical_record_id"] as? Int {
			rConsultation.recordId = recordId
		}
		// NOTE
		if let note = consultationDict["note"] as? String {
			rConsultation.note = note
		}
		// PHYSICAL EXAMS
		if let physical_exams = consultationDict["physical_exams"] as? [Dictionary<String, AnyObject>]{
			for PEDict in physical_exams {
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
				rConsultation.physicalExams.append(rPE)
			}
		}
		// PLAN
		if let planDict = consultationDict["plan"] as? Dictionary<String, AnyObject> {
			
			if let planId = planDict["id"] as? Int {
				let rPlan = RPlan()
				
				rPlan.id = planId
				
				if let planConsultationId = planDict["consultation_id"] as? Int {
					rPlan.consultationId = planConsultationId
				}
				if let planDescription = planDict["description"] as? String {
					rPlan.planDescription = planDescription
				}
				if let planEmergency = planDict["emergency"] as? Bool {
					rPlan.emergency = planEmergency
				}
				// NOTA OPERATORIA
				if let opNoteDict = planDict["operative_note"] as? Dictionary<String, AnyObject> {
					
					if let opNoteId = opNoteDict["id"] as? Int {
						let rOpNote = ROperativeNote()
						
						rOpNote.id = opNoteId
						
						if let opNoteDescription = opNoteDict["description"] as? String {
							rOpNote.opNoteDescription = opNoteDescription
						}
						if let opNoteFind = opNoteDict["find"] as? String {
							rOpNote.find = opNoteFind
						}
						if let opNoteDiagnostic = opNoteDict["diagnostic"] as? String {
							rOpNote.diagnostic = opNoteDiagnostic
						}
						if let opNoteCreatedDate = opNoteDict["created_at"] as? String {
							rOpNote.date = opNoteCreatedDate
						}
						
						rOpNote.planId = rPlan.id
						
						self.realm.add(rOpNote, update: true)
						rPlan.operativeNote = rOpNote
					}
				}
				// PROCEDIMIENTOS ASOCIADOS AL PLAN
				if let procedures = planDict["procedures"] as? [Dictionary<String, AnyObject>] {
					for procedureDict in procedures {
						
						let rProcedure = RProcedure()
						
						if let procedureId = procedureDict["id"] as? Int {
							rProcedure.id = procedureId
						}
						if let procedureName = procedureDict["name"] as? String {
							rProcedure.name = procedureName
						}
						if let procedureDescription = procedureDict["description"] as? String {
							rProcedure.procedureDescription = procedureDescription
						}
						
						self.realm.add(rProcedure, update: true)
						rPlan.procedures.append(rProcedure)
					}
				}
				
				self.realm.add(rPlan, update: true)
				rConsultation.plan = rPlan
			}
		}
		// PRESSURE_S
		if let pressure_s = consultationDict["pressure_s"] as? String {
			rConsultation.pressure_s = pressure_s
		}
		// PRESSURE_D
		if let pressure_d = consultationDict["pressure_d"] as? String {
			rConsultation.pressure_d = pressure_d
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
		// UPDATED AT
		if let lastUpdate = consultationDict["updated_at"] as? String {
			rConsultation.lastUpdate = lastUpdate.dateFromISO8601!
		}
		// WEIGHT
		if let weight = consultationDict["weight"] as? Int {
			rConsultation.weight = weight
		}
		
		return rConsultation
	}

	
	/// Descargar URL de Anexo (AWS)
	//
	func downloadAttachmentURL(id: Int, completed: @escaping (_ result: String) -> () ) {
		
		let attachmentURL = "\(URL_BASE)\(URL_ATTACHMENTS)\(id)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(attachmentURL, method: .get, headers: headers).responseJSON { (response) in
			
			var AWSURL = ""
			
			if let attachmentDict = response.result.value as? Dictionary<String, AnyObject> {
				
				if let url = attachmentDict["url"] as? String {
					
					AWSURL = url
				}
			}
			
			completed(AWSURL)
		}
	}
	
	
	/// Search de Historia
	//
	func searchRecord(search: String, completion: @escaping (_ result: [RMedicalRecord]) -> Void) {
		
		var searchResult = [RMedicalRecord]()
		
		let url = "\(URL_BASE)\(URL_SEARCH_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"search_param": search
		]
		
		Alamofire.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { response in
			
			if let dict = response.result.value as? [Dictionary<String, AnyObject>]{
				
				for recordDict in dict {
					
					let rMedRecord = self.parseSearchRecord(recordDict: recordDict)

					searchResult.append(rMedRecord)
				}
			}
			
			completion(searchResult)
		}
	}
	
	
	/// Parse simple de resultado de busqueda de historia
	//
	func parseSearchRecord(recordDict: Dictionary<String, AnyObject>) -> RMedicalRecord {
		
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
		// LAST NAME
		if let lastName = recordDict["last_name"] as? String {
			rMedRecord.lastName = lastName
		}
		// NAME
		if let name = recordDict["name"] as? String {
			rMedRecord.name = name
		}
		// PROFILE PICTURE URL
		if let profilePictureURL = recordDict["profile_picture"] as? String {
			rMedRecord.profilePicURL = profilePictureURL
		}
		
		return rMedRecord
	}
	
}

