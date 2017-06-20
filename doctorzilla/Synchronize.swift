//
//  Synchronize.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/14/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class Synchronize {
	
	let realm = try! Realm()
	var lastSync: Date!
	var lastSyncRLM: Date!
	var user: RUser!
	
	private var latestBackgrounds = [RBackground]()
	private var latestConsultations = [RConsultation]()
	private var latestMedicalRecords = [RMedicalRecord]()
	//private var latestOperativeNotes = [ROperativeNote]()
	private var latestPhysicalExams = [RPhysicalExam]()
	private var latestPlans = [RPlan]()
	
	/*
	private var latestBackgroundsRLM: Results<RBackground>!
	private var latestConsultationsRLM: Results<RConsultation>!
	private var latestMedicalRecordsRLM: Results<RMedicalRecord>!
	//private var latestOperativeNotesRLM: Results<ROperativeNote>!
	private var latestPhysicalExamsRLM: Results<RPhysicalExam>!
	private var latestPlansRLM: Results<RPlan>!
	*/
	
	private var latestBackgroundsRLM = [RBackground]()
	private var latestConsultationsRLM = [RConsultation]()
	private var latestMedicalRecordsRLM = [RMedicalRecord]()
	//private var latestOperativeNotesRLM = [ROperativeNote]()
	private var latestPhysicalExamsRLM = [RPhysicalExam]()
	private var latestPlansRLM = [RPlan]()
	
	func synchronizeDatabases(user: RUser, completed: @escaping DownloadComplete) {
		self.user = user
		self.lastSync {
			self.lastSynchRLM {
				print("FECHA SERVIDOR: \(self.lastSync)")
				print("FECHA REALM: \(self.lastSyncRLM)\n")
				if self.lastSync != nil && self.lastSyncRLM != nil && self.lastSync == self.lastSyncRLM {
					print("Comenzando sincronizacion...\n")
					self.latestUpdates {
						self.latestUpdatesRLM {
							self.syncBackgrounds()
							self.syncConsultations()
							self.syncMedicalRecordsBeta()
							//syncOperativeNotes()
							self.syncPhysicalExams()
							self.syncPlans()
							self.saveSync {
								//
							}
						}
					}
				} else {
					print("Descarga completa de datos...\n")
					dowloadOccupations {
						dowloadInsurances {
							dowloadDiagnostics {
								dowloadReasons {
									dowloadRecords(rUser: self.user) {
										downloadConsultations {
											/*
											downloadBackgrounds()
											dowloadPhysicalExams()
											downloadPlans{
											downloadOperativeNotes()
											}
											*/
											self.saveSync {
												//
											}
										}
									}
								}
							}
						}
					}
				}
				completed()
			}
		}
	}
	
	/// Fecha de ultima sincronizacion en Servidor
	//
	func lastSync(completed: @escaping DownloadComplete) {
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_LAST_SYNC)", method: .get, headers: headers).responseJSON { (response) in
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				if let lastSync = dict["sync_date"] as? String {
					self.lastSync = lastSync.dateFromISO8601
				}
			}
			completed()
		}
	}
	
	/// Fecha de ultima sincronizacion en Realm
	//
	func lastSynchRLM(completed: @escaping DownloadComplete) {
		self.lastSyncRLM = self.realm.objects(RSync.self).last?.date.iso8601.dateFromISO8601
		completed()
	}
	
	/// Carga de los records actualizados despues de la ultima fecha de sincronizacion. [Servidor]
	//
	func latestUpdates(completed: @escaping DownloadComplete) {
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_LATEST_UPDATES)", method: .get, headers: headers).responseJSON { (response) in
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				if let backgrounds = dict["backgrounds"] as? [Dictionary<String, AnyObject>] {
					for background in backgrounds {
						print(background)
					}
				}
				if let consultations = dict["consultations"] as? [Dictionary<String, AnyObject>] {
					self.latestConsultations.removeAll()
					for consultation in consultations {
						self.latestConsultations.append(parseConsultation(consultationDict: consultation))
					}
				}
				if let medicalRecords = dict["medical_records"] as? [Dictionary<String, AnyObject>] {
					self.latestMedicalRecords.removeAll()
					for record in medicalRecords {
						self.latestMedicalRecords.append(parseMedicalRecord(recordDict: record))
					}
				}
				if let operativeNotes = dict["operative_notes"] as? [Dictionary<String, AnyObject>] {
					for note in operativeNotes {
						print(note)
					}
				}
				if let physicalExams = dict["physical_exams"] as? [Dictionary<String, AnyObject>] {
					for exam in physicalExams {
						print(exam)
					}
				}
				if let plans = dict["plans"] as? [Dictionary<String, AnyObject>] {
					for plan in plans {
						print(plan)
					}
				}
			}
			completed()
		}
	}
	
	/// Carga de los records actualizados despues de la ultima fecha de sincronizacion. [Realm]
	//
	func latestUpdatesRLM(completed: @escaping DownloadComplete) {
		self.latestBackgroundsRLM = Array(self.realm.objects(RBackground.self).filter("lastUpdate > %@", self.lastSync))
		self.latestConsultationsRLM = Array(self.realm.objects(RConsultation.self).filter("lastUpdate > %@", self.lastSync))
		self.latestMedicalRecordsRLM = Array(self.realm.objects(RMedicalRecord.self).filter("lastUpdate > %@", self.lastSync))
		//self.latestOperativeNotesRLM = Array(self.realm.objects(ROperativeNote.self).filter("lastUpdate > %@", self.lastSync))
		self.latestPhysicalExamsRLM = Array(self.realm.objects(RPhysicalExam.self).filter("lastUpdate > %@", self.lastSync))
		self.latestPlansRLM = Array(self.realm.objects(RPlan.self).filter("lastUpdate > %@", self.lastSync))
		completed()
	}
	
	/// Guardar nueva fecha de sincronizacion. [Servidor y Realm]
	//
	func saveSync(completed: @escaping DownloadComplete) {
		let syncDate = Date().iso8601.dateFromISO8601!
		var syncDescription = "Sincronizacion"
		
		try! self.realm.write {
			let rSync = RSync()
			rSync.date = syncDate
			rSync.syncDescription = syncDescription
			self.realm.add(rSync)
			print("Nueva Sincronizacion guardada en Realm")
		}
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"sync": [
				"sync_date": syncDate,
				"description": syncDescription
			]
		]
		
		Alamofire.request("\(URL_BASE)\(URL_SYNCS)", method: .post, parameters: parameters, headers: headers).responseJSON { response in
			completed()
		}
	}
	
	/// Sincronizar Antecedentes
	//
	func syncBackgrounds() {
		if self.latestBackgrounds.count == 0 && self.latestBackgroundsRLM.count == 0 {
			print("Antecedentes al dia")
		} else if self.latestBackgrounds.count > 0 && self.latestBackgroundsRLM.count == 0 {
		
		} else if self.latestBackgrounds.count == 0 && self.latestBackgroundsRLM.count > 0 {
		
		} else if self.latestBackgrounds.count > 0 && self.latestBackgroundsRLM.count > 0 {
			
		}
	}
	
	/// Sincronizar Consultas
	//
	func syncConsultations() {
		if self.latestConsultations.count == 0 && self.latestConsultationsRLM.count == 0 {
			print("Consultas al dia")
		} else  {
			try! self.realm.write {
				// Check de las actualizaciones en Realm.
				for consultation in latestConsultationsRLM {
					if let serverConsultationLastUpdate = latestConsultations.filter({$0.id == consultation.id}).first {
						print("Conflicto de Realm con Servidor")
						if consultation.lastUpdate > serverConsultationLastUpdate.lastUpdate {
							print("< Realm --> Servidor >")
							/*
							updateConsultation(consultation: consultation, completed: {
								//
							})
							*/
						} else {
							print("< Servidor --> Realm >")
							/*
							serverConsultationLastUpdate.user = self.user
							self.realm.add(serverConsultationLastUpdate, update: true)
							*/
						}
					} else {
						print("< Realm --> Servidor >")
						/*
						updateConsultation(consultation: consultation, completed: {
							//
						})
						*/
					}
				}
				
				// Check de las actualizaciones en la Web.
				for consultation in latestConsultations {
					if let realmConsultationLastUpdate = latestConsultationsRLM.filter({$0.id == consultation.id}).first {
						print("Conflicto de Servidor  con Realm")
						if consultation.lastUpdate > realmConsultationLastUpdate.lastUpdate {
							print("< Servidor --> Realm >")
							/*
							consultation.user = self.user
							self.realm.add(consultation, update: true)
							*/
						} else {
							print("< Realm --> Servidor >")
							/*
							updateConsultation(consultation: realmConsultationLastUpdate, completed: {
								//
							})
							*/
						}
					} else {
						print("< Servidor --> Realm >")
						/*
						consultation.user = self.user
						self.realm.add(consultation, update: true)
						*/
					}
					
				}
			}
		}
	}
	
	/// Sincronizar Historias PRUEBA
	//
	func syncMedicalRecordsBeta() {
		if self.latestMedicalRecords.count == 0 && self.latestMedicalRecordsRLM.count == 0 {
			print("Historias Medicas al dia")
		} else {
			print("\n")
			try! self.realm.write {
				// Check de las actualizaciones en Realm.
				for record in self.latestMedicalRecordsRLM {
					if let serverRecordLastUpdate = latestMedicalRecords.filter({$0.id == record.id}).first {
						if record.lastUpdate > serverRecordLastUpdate.lastUpdate {
							print("  Conflicto de Realm con Servidor\n    < Realm --> Servidor >")
							updateRecord(record: record, completed: {})
						}
					} else {
						print("  < Realm --> Servidor >")
						updateRecord(record: record, completed: {})
					}
				}
				
				// Check de las actualizaciones en la Web.
				for record in self.latestMedicalRecords {
					if let realmRecordLastUpdate = latestMedicalRecordsRLM.filter({$0.id == record.id}).first {
						if record.lastUpdate > realmRecordLastUpdate.lastUpdate {
							print("  Conflicto de Servidor  con Realm\n    < Servidor --> Realm >")
							record.user = self.user
							self.realm.add(record, update: true)
						}
					} else {
						print("  < Servidor --> Realm >")
						record.user = self.user
						self.realm.add(record, update: true)
					}
				}
			}
			print("\n")
		}
	}
	
	/*
	/// Sincronizar Notas Operatorias
	//
	func syncOperativeNotes() {
		if self.latestOperativeNotes.count == 0 && self.latestOperativeNotesRLM.count == 0 {
			print("Historias Medicas al dia")
		} else if self.latestOperativeNotes.count > 0 && self.latestOperativeNotesRLM.count == 0 {
	
		} else if self.latestOperativeNotes.count == 0 && self.latestOperativeNotesRLM.count > 0 {
	
		} else if self.latestOperativeNotes.count > 0 && self.latestOperativeNotesRLM.count > 0 {
	
		}
	}
	*/
	
	/// Sincronizar Examenes Fisicos
	//
	func syncPhysicalExams() {
		if self.latestPhysicalExams.count == 0 && self.latestPhysicalExamsRLM.count == 0 {
			print("Examenes fisicos al dia")
		} else if self.latestPhysicalExams.count > 0 && self.latestPhysicalExamsRLM.count == 0 {
		
		} else if self.latestPhysicalExams.count == 0 && self.latestPhysicalExamsRLM.count > 0 {
		
		} else if self.latestPhysicalExams.count > 0 && self.latestPhysicalExamsRLM.count > 0 {
			
		}
	}
	
	/// Sincronizar Planes
	//
	func syncPlans() {
		if self.latestPlans.count == 0 && self.latestPlansRLM.count == 0 {
			print("Planes al dia")
		} else if self.latestPlans.count > 0 && self.latestPlansRLM.count == 0 {
		
		} else if self.latestPlans.count == 0 && self.latestPlansRLM.count > 0 {
			
		} else if self.latestPlans.count > 0 && self.latestPlansRLM.count > 0 {
			
		}
	}
	
	
}




















