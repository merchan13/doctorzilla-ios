//
//  RProcedure.swift
//  doctorzilla
//
//  Created by Javier Merchán on 8/16/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RProcedure: Object {
	dynamic var id = 0
	dynamic var name = ""
	dynamic var procedureDescription = ""
	
	let plans = LinkingObjects(fromType: RPlan.self, property: "procedures")
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
