//
//  RReason.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RReason: Object {
	dynamic var id = 0
	dynamic var reasonDescription = ""
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
