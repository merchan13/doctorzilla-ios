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
	@objc dynamic var date = ""
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func parsedCreationDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		
		if let date: Date = dateFormatterGet.date(from: self.date){
			parsedDate = dateFormatterResult.string(from: date)
		}
		
		return parsedDate
	}
	
}
