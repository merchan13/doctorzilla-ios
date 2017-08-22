//
//  DataHelperRLM.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/22/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class DataHelperRLM {
	let realm = try! Realm()
	
	/// Actualizar Historia Medica [Realm]
	//
	func updateMedicalRecord(record: RMedicalRecord) {
		if self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: record.id) != nil {
			
			let newData =	[
				"id": record.id,
				"name": record.name,
				"lastName": record.lastName,
				"birthday": record.birthday,
				"email": record.email,
				"phone": record.phone,
				"cellphone": record.cellphone,
				"address": record.address,
				"gender": record.gender,
				"referredBy": record.referredBy,
				"lastUpdate": record.lastUpdate,
				"profilePicURL": record.profilePicURL
				] as [String : Any]
			
			self.realm.create(RMedicalRecord.self, value: newData, update: true)
			
			if let occupation = record.occupation {
				self.realm.create(RMedicalRecord.self, value: ["id": record.id, "occupation":occupation], update: true)
			}
			
			if let insurance = record.insurance {
				self.realm.create(RMedicalRecord.self, value: ["id": record.id, "insurance":insurance], update: true)
			}
			self.realm.create(RMedicalRecord.self, value: ["id": record.id, "reports":record.reports], update: true)
			self.realm.create(RMedicalRecord.self, value: ["id": record.id, "attachments":record.attachments], update: true)
			self.realm.create(RMedicalRecord.self, value: ["id": record.id, "backgrounds":record.backgrounds], update: true)
			
		} else {
			self.realm.add(record, update: true)
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			record.user = user
		}
	}
	
	/// /// Actualizar Consulta [Realm]
	//
	func updateConsultation(consultation: RConsultation) {
		if self.realm.object(ofType: RConsultation.self, forPrimaryKey: consultation.id) != nil {
			
			let newData =	[
								"id": consultation.id,
								"date": consultation.date,
								"affliction": consultation.affliction,
								"evolution": consultation.evolution,
								"height": consultation.height,
								"weight": consultation.weight,
								"pressure_s": consultation.pressure_s,
								"pressure_d": consultation.pressure_d,
								"note": consultation.note,
								"lastUpdate": consultation.lastUpdate
			               	] as [String : Any]
			
			self.realm.create(RConsultation.self, value: newData, update: true)
			
			if let diagnostic = consultation.diagnostic {
				self.realm.create(RConsultation.self, value: ["id": consultation.id, "diagnostic":diagnostic], update: true)
			}
			
			if let reason = consultation.reason {
				self.realm.create(RConsultation.self, value: ["id": consultation.id, "reason":reason], update: true)
			}
			self.realm.create(RConsultation.self, value: ["id": consultation.id, "physicalExams":consultation.physicalExams], update: true)
		} else {
			if let record = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: consultation.recordId) {
				self.realm.add(consultation, update: true)
				record.consultations.append(consultation)
			}
		}
	}
}
