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
	dynamic var id = 0
	dynamic var backgroundType = ""
	dynamic var backgroundDescription = ""
		
	override static func primaryKey() -> String? {
		return "id"
	}
}
