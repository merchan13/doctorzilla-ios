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
	@objc dynamic var id = 0
	@objc dynamic var examType = ""
	@objc dynamic var observation = ""
	@objc dynamic var lastUpdate = Date()
	@objc dynamic var consultationId = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
