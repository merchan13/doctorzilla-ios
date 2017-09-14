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
	dynamic var id = 0
	dynamic var diagnosticDescription = ""
	dynamic var lastUpdate = Date()
	
	let consultations = LinkingObjects(fromType: RConsultation.self, property: "diagnostics")
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
