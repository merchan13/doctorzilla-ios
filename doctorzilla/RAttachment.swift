//
//  RAttachment.swift
//  doctorzilla
//
//  Created by Javier Merchán on 8/16/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RAttachment: Object {
	@objc dynamic var id = 0
	@objc dynamic var attachmentDescription = ""
	@objc dynamic var recordId = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
