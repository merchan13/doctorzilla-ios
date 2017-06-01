//
//  PhysicalExam.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/31/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class PhysicalExam {
	
	private var _PEURL: String!
	private var _PEId: Int!
	private var _PEType: String!
	private var _observation: String!

	var PEId: Int {
		if _PEId == nil {
			_PEId = 0
		}
		return _PEId
	}
	
	var PEType: String {
		if _PEType == nil {
			_PEType = ""
		}
		return _PEType
	}
	
	var observation: String {
		if _observation == nil {
			_observation = ""
		}
		return _observation
	}
	
	init(PEId: Int, PEType: String, observation: String) {
		
		self._PEId = PEId
		self._PEType = PEType
		self._observation = observation
		
		self._PEURL = "\(URL_BASE)\(URL_PHYSICAL_EXAMS)\(self.PEId)/"
	}

}
