//
//  MedicalRecord.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/23/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire

class MedicalRecord {
	
	private var _medrecordURL: String!
	private var _recordId: Int!
	private var _name: String!
	private var _lastName: String!
	private var _document: String!
	
	var recordId: Int {
		if _recordId == nil {
			_recordId = 0
		}
		return _recordId
	}
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		return _name
	}
	
	var lastName: String {
		if _lastName == nil {
			_lastName = ""
		}
		return _lastName
	}
	
	var document: String {
		if _document == nil {
			_document = ""
		}
		return _document
	}
	
	init(recordId: Int, lastName: String, document: String) {
		
		self._recordId = recordId
		self._lastName = lastName
		self._document = document
		
		self._medrecordURL = "\(URL_BASE)\(URL_MEDICAL_RECORDS)\(self.recordId)/"
	}
	
	func downloadRecordDetails(completed: @escaping DownloadComplete) {
		
		Alamofire.request(_medrecordURL, method: .get).responseJSON { (response) in
			
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				
				//...
				
			}
			completed()
		}
		
	}
	
}
