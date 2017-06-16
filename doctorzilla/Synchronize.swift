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
	
	private var latestBackgrounds = [RBackground]()
	private var latestConsultations = [RConsultation]()
	private var latestMedicalRecords = [RMedicalRecord]()
	//private var latestOperativeNotes = [ROperativeNote]()
	private var latestPhysicalExams = [RPhysicalExam]()
	private var latestPlans = [RPlan]()
	
	private var latestBackgroundsRLM: Results<RBackground>!
	private var latestConsultationsRLM: Results<RConsultation>!
	private var latestMedicalRecordsRLM: Results<RMedicalRecord>!
	//private var latestOperativeNotesRLM: Results<ROperativeNote>!
	private var latestPhysicalExamsRLM: Results<RPhysicalExam>!
	private var latestPlansRLM: Results<RPlan>!
	
	func synchronizeDatabases(user: RUser, completed: @escaping DownloadComplete) {
		self.lastSync {
			self.lastSynchRLM {
				if self.lastSync != nil && self.lastSyncRLM != nil && self.lastSync == self.lastSyncRLM {
					print("Comenzando sincronizacion...\n")
					self.latestUpdates {
						self.latestUpdatesRLM {
							self.syncBackgrounds()
							self.syncConsultations()
							self.syncMedicalRecords()
							//syncOperativeNotes()
							self.syncPhysicalExams()
							self.syncPlans()
						}
					}
				} else {
					print("Descarga completa de datos...\n")
					dowloadOccupations {
						dowloadInsurances {
							dowloadDiagnostics {
								dowloadReasons {
									dowloadRecords(rUser: user) {
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
					for consultation in consultations {
						self.latestConsultations.append(parseConsultation(consultationDict: consultation))
					}
				}
				if let medicalRecords = dict["medical_records"] as? [Dictionary<String, AnyObject>] {
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
		self.latestBackgroundsRLM = self.realm.objects(RBackground.self).filter("lastUpdate > %@", self.lastSync)
		self.latestConsultationsRLM = self.realm.objects(RConsultation.self).filter("lastUpdate > %@", self.lastSync)
		self.latestMedicalRecordsRLM = self.realm.objects(RMedicalRecord.self).filter("lastUpdate > %@", self.lastSync)
		//self.latestOperativeNotesRLM = self.realm.objects(ROperativeNote.self).filter("lastUpdate > %@", self.lastSync)
		self.latestPhysicalExamsRLM = self.realm.objects(RPhysicalExam.self).filter("lastUpdate > %@", self.lastSync)
		self.latestPlansRLM = self.realm.objects(RPlan.self).filter("lastUpdate > %@", self.lastSync)
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
			// descargar a realm
		} else if self.latestBackgrounds.count == 0 && self.latestBackgroundsRLM.count > 0 {
			// actualizar servidor
		} else if self.latestBackgrounds.count > 0 && self.latestBackgroundsRLM.count > 0 {
			// actualizar con resolucion de conflictos.
		}
	}
	
	/// Sincronizar Consultas
	//
	func syncConsultations() {
		if self.latestConsultations.count == 0 && self.latestConsultationsRLM.count == 0 {
			print("Consultas al dia")
		} else if self.latestConsultations.count > 0 && self.latestConsultationsRLM.count == 0 {
			// descargar a realm
			print(2)
		} else if self.latestConsultations.count == 0 && self.latestConsultationsRLM.count > 0 {
			// actualizar servidor
			print("Caso 3 [consultas]")
			print(self.latestConsultationsRLM.count)
		} else if self.latestConsultations.count > 0 && self.latestConsultationsRLM.count > 0 {
			// actualizar con resolucion de conflictos.
			print(4)
		}
	}
	
	/// Sincronizar Historias
	//
	func syncMedicalRecords() {
		if self.latestMedicalRecords.count == 0 && self.latestMedicalRecordsRLM.count == 0 {
			print("Historias Medicas al dia")
		} else if self.latestMedicalRecords.count > 0 && self.latestMedicalRecordsRLM.count == 0 {
			// descargar a realm
		} else if self.latestMedicalRecords.count == 0 && self.latestMedicalRecordsRLM.count > 0 {
			// actualizar servidor
		} else if self.latestMedicalRecords.count > 0 && self.latestMedicalRecordsRLM.count > 0 {
			// actualizar con resolucion de conflictos.
		}
	}
	
	/*
	func syncOperativeNotes() {
		if self.latestOperativeNotes.count == 0 && self.latestOperativeNotesRLM.count == 0 {
			print("Historias Medicas al dia")
		} else if self.latestOperativeNotes.count > 0 && self.latestOperativeNotesRLM.count == 0 {
			// descargar a realm
		} else if self.latestOperativeNotes.count == 0 && self.latestOperativeNotesRLM.count > 0 {
			// actualizar servidor
		} else if self.latestOperativeNotes.count > 0 && self.latestOperativeNotesRLM.count > 0 {
			// actualizar con resolucion de conflictos.
		}
	}
	*/
	
	/// Sincronizar Examenes Fisicos
	//
	func syncPhysicalExams() {
		if self.latestPhysicalExams.count == 0 && self.latestPhysicalExamsRLM.count == 0 {
			print("Examenes fisicos al dia")
		} else if self.latestPhysicalExams.count > 0 && self.latestPhysicalExamsRLM.count == 0 {
			// descargar a realm
		} else if self.latestPhysicalExams.count == 0 && self.latestPhysicalExamsRLM.count > 0 {
			// actualizar servidor
		} else if self.latestPhysicalExams.count > 0 && self.latestPhysicalExamsRLM.count > 0 {
			// actualizar con resolucion de conflictos.
		}
	}
	
	/// Sincronizar Plans
	//
	func syncPlans() {
		if self.latestPlans.count == 0 && self.latestPlansRLM.count == 0 {
			print("Planes al dia")
		} else if self.latestPlans.count > 0 && self.latestPlansRLM.count == 0 {
			// descargar a realm
		} else if self.latestPlans.count == 0 && self.latestPlansRLM.count > 0 {
			// actualizar servidor
		} else if self.latestPlans.count > 0 && self.latestPlansRLM.count > 0 {
			// actualizar con resolucion de conflictos.
		}
	}
	
	
}




















