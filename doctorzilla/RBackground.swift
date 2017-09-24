//
//  RBackground.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RBackground: Object {
	@objc dynamic var id = 0
	@objc dynamic var backgroundType = ""
	@objc dynamic var backgroundDescription = ""
	@objc dynamic var lastUpdate = Date()
	@objc dynamic var recordId = 0
		
	override static func primaryKey() -> String? {
		return "id"
	}
}
