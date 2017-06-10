//
//  RPhysicalExam.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RPhysicalExam: Object {
	dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
