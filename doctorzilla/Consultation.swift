//
//  Consultation.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/29/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire

class Consultation {

	private var _consultationURL: String!
	private var _consultationId: Int!
	private var _date: String!
	private var _reason: String!
	private var _affliction: String!
	private var _diagnostic: String!
	private var _evolution: String!
	private var _height: Int!
	private var _weight: Int!
	private var _pressure_s: String!
	private var _pressure_d: String!
	private var _note: String!
	private var _plan: String!
	private var _backgrounds = [Background]()
	private var _physicalExams = [PhysicalExam]()
	
	var consultationId: Int {
		if _consultationId == nil {
			_consultationId = 0
		}
		return _consultationId
	}
	
	var date: String {
		if _date == nil {
			_date = ""
		}
		return _date
	}
	
	var reason: String {
		if _reason == nil {
			_reason = ""
		}
		return _reason
	}
	
	var affliction: String {
		if _affliction == nil {
			_affliction = ""
		}
		return _affliction
	}
	
	var diagnostic: String {
		if _diagnostic == nil {
			_diagnostic = ""
		}
		return _diagnostic
	}
	
	var evolution: String {
		if _evolution == nil {
			_evolution = ""
		}
		return _evolution
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
	
	var note: String {
		if _note == nil {
			_note = ""
		}
		return _note
	}
	
	var plan: String {
		if _plan == nil {
			_plan = ""
		}
		return _plan
	}
	
	var backgrounds: [Background] {
		return _backgrounds
	}
	
	var physicalExams: [PhysicalExam] {
		return _physicalExams
	}
	
	init(consultationId: Int, date: String, reason: String) {
		
		self._consultationId = consultationId
		self._date = date
		self._reason = reason
		
		self._consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)\(self.consultationId)/"
	}
	
	func downloadConsultationDetails(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(_consultationURL, method: .get, headers: headers).responseJSON { (response) in
			
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				
				// AFFLICTION
				if let affliction = dict["affliction"] as? String {
					self._affliction = affliction
				}
				
				// DIAGNOSTIC
				if let diagnosticDict = dict["diagnostic"] as? Dictionary<String, AnyObject> {
					if let diagnostic = diagnosticDict["description"] as? String {
						self._diagnostic = diagnostic
					}
				}
				
				// EVOLUTION
				if let evolution = dict["evolution"] as? String {
					self._evolution = evolution
				}
				
				// HEIGHT
				if let height = dict["height"] as? Int {
					self._height = height
				}
				
				// WEIGHT
				if let weight = dict["weight"] as? Int {
					self._weight = weight
				}
				
				// PRESSURE_S
				if let pressure_s = dict["pressure_s"] as? String {
					self._pressure_s = pressure_s
				}
				
				// PRESSURE_D
				if let pressure_d = dict["pressure_d"] as? String {
					self._pressure_d = pressure_d
				}
				
				// NOTE
				if let note = dict["note"] as? String {
					self._note = note
				}
				
				// PLAN
				if let plan = dict["plan"] as? String {
					self._plan = plan
				}
				
				// BACKGROUNDS
				if let backgrounds = dict["backgrounds"] as? [Dictionary<String, AnyObject>] {
					for bg in backgrounds {
						self._backgrounds.append(Background(backgroundType: bg["background_type"] as! String, backgroundDescription: bg["description"] as! String))
					}
				}
				
				// PHYSICAL_EXAMS
				if let physicalExams = dict["physical_exams"] as? [Dictionary<String,AnyObject>] {
					for pe in physicalExams {
						self._physicalExams.append(PhysicalExam(PEId: pe["id"] as! Int, PEType: pe["exam_type"] as! String, observation: pe["observation"] as! String!))
					}
				}
				
			}
			completed()
		}
		
	}
	
	func parsedConsultationDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		if let consultationDate = self._date {
			if let date: Date = dateFormatterGet.date(from: consultationDate){
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
