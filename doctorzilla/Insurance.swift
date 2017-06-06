//
//  Insurance.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/5/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class Insurance {

	private var _insuranceURL: String!
	private var _insuranceId: Int!
	private var _name: String!
	
	var insuranceId: Int {
		if _insuranceId == nil {
			_insuranceId = 0
		}
		return _insuranceId
	}
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		return _name
	}
	
	init(insuranceId: Int, name: String) {
		
		self._insuranceId = insuranceId
		self._name = name
		
		self._insuranceURL = "\(URL_BASE)\(URL_INSURANCES)\(self.insuranceId)/"
	}
	
}
