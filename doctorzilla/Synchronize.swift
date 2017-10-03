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
		
		self.recordsUpdateDictionary { (result: [Dictionary<String, AnyObject>]) in
			
			for actionDict in result {
			
				if let action = actionDict["action"] as? Int {
					
					// Subir (Realm -> Server)
					if action == 1 {
						
						if let record = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: actionDict["id"]) {
							
							self.dataHelper.updateRecord(record: record, completed: {
								
								let consultations = record.consultations
								
								for consultation in consultations {
								
									if consultation.reason == nil {
										
										self.dataHelper.createConsultation(consultation: consultation, completed: {
											
											print("\nSincronizacion[1]: realm -> server")
										})
									}
								}
								
								
							})
						}
					}
					// Descargar (Server -> Realm)
					else if action == 2 {
						
						if let record = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: actionDict["id"]) {
							
							self.dataHelper.downloadRecord(recordId: record.id, completed: {
								
								self.dataHelper.downloadConsultations(recordId: record.id, completed: {
									
									print("\nSincronizacion[2]: server -> realm")
								})
							})
						}
					}
				}
			}
		}
	}
	
	
	/// Diccionario de fechas de actualizacion e ids de historias
	//
	func recordsUpdateDictionary(completed: @escaping (_ result: [Dictionary<String, AnyObject>]) -> Void) {
		
		let records = self.realm.objects(RMedicalRecord.self)
		
		var recordsDictionary = [String:Any]()
		var actionsDictionary = [Dictionary<String, AnyObject>]()
		
		for record in records {
			
			recordsDictionary["\(record.id)"] = "\(record.lastUpdate.iso8601)"
		}
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let parameters: Parameters = [
			"sync": [
				"records_dictionary": recordsDictionary
			]
		]
		
		Alamofire.request("\(URL_BASE)\(URL_SET_ACTIONS)", method: .post, parameters: parameters, headers: headers).responseJSON { response in
			
			if let actions = response.result.value as? [Dictionary<String, AnyObject>] {
				
				actionsDictionary = actions
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




















