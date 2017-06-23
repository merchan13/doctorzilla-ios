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
		} else {
			if let record = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: consultation.recordId) {
				self.realm.add(consultation, update: true)
				record.consultations.append(consultation)
			}
		}
	}
	
	/// Actualizar Antecedente [Realm]
	//
	func updateBackground(background: RBackground) {
		//
	}
	
	/// Actualizar Examen Fisico [Realm]
	//
	func updatePhysicalExam(physicalExam: RPhysicalExam) {
		//
	}
	
	/// Actualizar Plan [Realm]
	//
	func updatePlan(plan: RPlan) {
		//
	}
	
}
