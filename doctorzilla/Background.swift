//
//  Background.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/26/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class Background {

	private var _backgroundId: Int!
	private var _backgroundType: String!
	private var _backgroundDescription: String!
	
	var backgroundId: Int {
		if _backgroundId == nil {
			_backgroundId = 0
		}
		return _backgroundId
	}
	
	var backgroundType: String {
		if _backgroundType == nil {
			_backgroundType = ""
		}
		return _backgroundType
	}
	
	var backgroundDescription: String {
		if _backgroundDescription == nil {
			_backgroundDescription = ""
		}
		return _backgroundDescription
	}
	
	init(backgroundId: Int, backgroundType: String, backgroundDescription: String) {
		
		self._backgroundId = backgroundId
		self._backgroundType = backgroundType
		self._backgroundDescription = backgroundDescription
		
	}

}
