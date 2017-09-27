//
//  RDiagnostic.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/9/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RDiagnostic: Object {
	@objc dynamic var id = 0
	@objc dynamic var diagnosticDescription = ""
	@objc dynamic var lastUpdate = Date()
	
	let consultations = LinkingObjects(fromType: RConsultation.self, property: "diagnostics")
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func parsedDate() -> String {
		var parsedDate = " "
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		let dateFormatterResult = DateFormatter()
		dateFormatterResult.dateFormat = "dd MMM yyyy"
		
		
		if let date: Date = dateFormatterGet.date(from: self.lastUpdate.iso8601){
			parsedDate = dateFormatterResult.string(from: date)
		}
		
		return parsedDate
	}
}
