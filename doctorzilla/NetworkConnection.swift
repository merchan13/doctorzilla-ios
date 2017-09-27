//
//  NetworkConnection.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/27/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class NetworkConnection {
	
	static var sharedInstance = NetworkConnection()
	private init() {}
	
	var haveConnection: Bool!
	
}
