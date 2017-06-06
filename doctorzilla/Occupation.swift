//
//  Occupation.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/5/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class Occupation {

	private var _occupationURL: String!
	private var _occupationId: Int!
	private var _name: String!
	
	var occupationId: Int {
		if _occupationId == nil {
			_occupationId = 0
		}
		return _occupationId
	}
	
	var name: String {
		if _name == nil {
			_name = ""
		}
		return _name
	}
	
	init(occupationId: Int, name: String) {
		
		self._occupationId = occupationId
		self._name = name
		
		self._occupationURL = "\(URL_BASE)\(URL_OCCUPATIONS)\(self.occupationId)/"
	}
	
}
