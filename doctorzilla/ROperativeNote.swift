//
//  ROperativeNote.swift
//  doctorzilla
//
//  Created by Javier Merchán on 8/16/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class ROperativeNote: Object {
	dynamic var id = 0
	dynamic var noteDescription = ""
	dynamic var find = ""
	dynamic var planId = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
