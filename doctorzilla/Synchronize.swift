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
	let dataHelper = DataHelper()
	let dataHelperRLM = DataHelperRLM()
	var lastSync: Date!
	var lastSyncRLM: Date!
	var user: RUser!
	
	private var latestConsultations = [RConsultation]()
	private var latestMedicalRecords = [RMedicalRecord]()
	
	private var latestBackgroundsRLM = [RBackground]()
	private var latestConsultationsRLM = [RConsultation]()
	private var latestMedicalRecordsRLM = [RMedicalRecord]()
	private var latestPhysicalExamsRLM = [RPhysicalExam]()
	
	private var newData = false
	
	
	func synchronizeDatabases(completed: @escaping DownloadComplete) {
		
		self.recordsUpdateDictionary { (result: [Int:Int]) in
			
			// TEST THIS!!
			print(result)
		}
	}
	
	
	/// Diccionario de fechas de actualizacion e ids de historias
	//
	func recordsUpdateDictionary(completed: @escaping (_ result: [Int:Int]) -> Void) {
		
		let records = self.realm.objects(RMedicalRecord.self)
		
		var recordsDictionary = [String:Any]()
		var actionsDictionary = [Int:Int]()
		
		for record in records {
			
			recordsDictionary["\(record.id)"] = "\(record.lastUpdate.iso8601)"
		}
		
		print(recordsDictionary)
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"sync": [
				"records_dictionary": recordsDictionary
			]
		]
		
		print(parameters)
		
		//let parameters: Parameters = recordsDictionary
		
		Alamofire.request("\(URL_BASE)\(URL_SET_ACTIONS)", method: .post, parameters: parameters, headers: headers).responseJSON { response in
			
			if let actions = response.result.value as? [Dictionary<String, AnyObject>] {
				
				for dict in actions {
					
					if let recordId = dict["id"] as? Int {
						
						if let recordAction = dict["action"] as? Int {
							
							actionsDictionary[recordId] = recordAction
						}
					}
				}
			}
			
			completed(actionsDictionary)
		}
	}
	
	
	/// Descargar todos los datos cuando se inicia sesion por primera vez (NEW)
	//
	func downloadRecords(completed: @escaping DownloadComplete) {
		
		self.dataHelper.downloadOccupations { print("Occupations DONE")
			
			self.dataHelper.downloadInsurances { print("Insurances DONE")
				
				self.dataHelper.downloadReasons { print("Reasons DONE")
					
					self.latestUpdates {
						
						try! self.realm.write {
							
							for record in self.latestMedicalRecords {
								
								self.dataHelperRLM.updateMedicalRecord(record: record)
							}
							print("Records DONE")
							
							for consultation in self.latestConsultations {
								
								self.dataHelperRLM.updateConsultation(consultation: consultation)
							}
							print("Consultations DONE")
						}
						
						completed()
					}
				}
			}
		}
	}
	
	
	/// Fecha de ultima sincronizacion en Servidor (IN USE) (CHECK!!)
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
	
	
	/// Fecha de ultima sincronizacion en Realm (IN USE) (CHECK!!)
	//
	func lastSynchRLM(completed: @escaping DownloadComplete) {
		
		self.lastSyncRLM = self.realm.objects(RSync.self).last?.date.iso8601.dateFromISO8601
		
		completed()
	}
	
	
	/// Carga de los Xs Records mas actualizados (IN USE)
	//
	func latestUpdates(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_LATEST_UPDATES)", method: .get, headers: headers).responseJSON { (response) in
			
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				
				if let medicalRecords = dict["medical_records"] as? [Dictionary<String, AnyObject>] {
					
					self.latestMedicalRecords.removeAll()
					
					for record in medicalRecords {
						
						try! self.realm.write {
							
							self.latestMedicalRecords.append(self.dataHelper.parseMedicalRecord(recordDict: record))
						}
					}
				}
				
				if let consultations = dict["consultations"] as? [Dictionary<String, AnyObject>] {
					
					self.latestConsultations.removeAll()
					
					for consultation in consultations {
						
						try! self.realm.write {
							
							self.latestConsultations.append(self.dataHelper.parseConsultation(consultationDict: consultation))
						}
					}
				}
			}
			
			completed()
		}
	}
	
	
	/// Carga de los records actualizados despues de la ultima fecha de sincronizacion. [Realm]
	//
	func latestUpdatesRLM(completed: @escaping DownloadComplete) {
		
		self.latestMedicalRecordsRLM = Array(self.realm.objects(RMedicalRecord.self).filter("lastUpdate > %@", self.lastSync))
		
		
		self.latestConsultationsRLM = Array(self.realm.objects(RConsultation.self).filter("lastUpdate > %@", self.lastSync))
		
		completed()
	}
	
	
	/// Guardar nueva fecha de sincronizacion. [Servidor y Realm]
	//
	func saveSync(syncDesc: String, completed: @escaping DownloadComplete) {
		
		let syncDate = Date().iso8601.dateFromISO8601!
		
		let syncDescription = syncDesc
		
		try! self.realm.write {
			
			let rSync = RSync()
			
			rSync.date = syncDate
			
			rSync.syncDescription = syncDescription
			
			self.realm.add(rSync)
			
			print("\nNueva Sincronizacion guardada en Realm\n")
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
	
	
	/// Sincronizar Historias
	//
	func syncMedicalRecords() {
		if self.latestMedicalRecords.count == 0 && self.latestMedicalRecordsRLM.count == 0 {
			print("Historias Medicas al dia")
		} else {
			print("Historias")
			
			self.newData = true
			
			try! self.realm.write {
				// Check de las actualizaciones en Realm.
				for record in self.latestMedicalRecordsRLM {
					if let serverRecordLastUpdate = self.latestMedicalRecords.filter({$0.id == record.id}).first {
						if record.lastUpdate > serverRecordLastUpdate.lastUpdate {
							print("    Conflicto de Realm con Servidor\n      < Realm --> Servidor >")
							self.dataHelper.updateRecord(record: record, completed: {
								self.dataHelper.updateBackgrounds(record: record, recordBgs: record.backgrounds, completed: { 
									self.dataHelper.fixNewBackgrounds(record: record, recordBgs: record.backgrounds, completed: { 
										// Do nothing..
									})
								})
							})
						}
					} else {
						print("    < Realm --> Servidor >")
						self.dataHelper.updateRecord(record: record, completed: {
							self.dataHelper.updateBackgrounds(record: record, recordBgs: record.backgrounds, completed: {
								self.dataHelper.fixNewBackgrounds(record: record, recordBgs: record.backgrounds, completed: {
									// Do nothing..
								})
							})
						})
					}
				}
				
				// Check de las actualizaciones en la Web.
				for record in self.latestMedicalRecords {
					if let realmRecordLastUpdate = self.latestMedicalRecordsRLM.filter({$0.id == record.id}).first {
						if record.lastUpdate > realmRecordLastUpdate.lastUpdate {
							print("    Conflicto de Servidor  con Realm\n      < Servidor --> Realm >")
							self.dataHelperRLM.updateMedicalRecord(record: record)
						}
					} else {
						print("    < Servidor --> Realm >")
						self.dataHelperRLM.updateMedicalRecord(record: record)
					}
				}
			}
		}
	}
	
	
	/// Sincronizar Consultas
	//
	func syncConsultations() {
		if self.latestConsultations.count == 0 && self.latestConsultationsRLM.count == 0 {
			print("Consultas al dia")
		} else  {
			print("Consultas")
			
			self.newData = true
			
			try! self.realm.write {
				// Check de las actualizaciones en Realm.
				for consultation in self.latestConsultationsRLM {
					if let serverConsultationLastUpdate = self.latestConsultations.filter({$0.id == consultation.id}).first {
						if consultation.lastUpdate > serverConsultationLastUpdate.lastUpdate {
							print("    Conflicto de Realm con Servidor\n      < Realm --> Servidor >")
							self.dataHelper.updateConsultation(consultation: consultation, completed: {})
						}
					} else {
						print("    < Realm --> Servidor >")
						self.dataHelper.updateConsultation(consultation: consultation, completed: {})
					}
				}
				
				// Check de las actualizaciones en la Web.
				for consultation in self.latestConsultations {
					if let realmConsultationLastUpdate = self.latestConsultationsRLM.filter({$0.id == consultation.id}).first {
						if consultation.lastUpdate > realmConsultationLastUpdate.lastUpdate {
							print("    Conflicto de Servidor  con Realm\n      < Servidor --> Realm >")
							self.dataHelperRLM.updateConsultation(consultation: consultation)
						}
					} else {
						print("    < Servidor --> Realm >")
						self.dataHelperRLM.updateConsultation(consultation: consultation)
					}
				}
			}
		}
	}
	
	
	/// Borrar la BD y descargar toda la informacion.
	//
	func resetDatabase(completed: @escaping DownloadComplete) {
		
		try! self.realm.write {
			
			self.realm.deleteAll()
			
			let user = User()
			
			user.signOut {
				completed()
			}
		}
	}

}




















