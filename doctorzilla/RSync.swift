//
//  RSync.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/15/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

class RSync: Object {
	@objc dynamic var date = Date()
	@objc dynamic var syncDescription = ""	
}
