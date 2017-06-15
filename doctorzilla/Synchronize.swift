//
//  Synchronize.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/14/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class Synchronize {
	
	var lastSynch = ""
	
	func lastSynch(completed: @escaping DownloadComplete) {
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_LAST_SYNCH)", method: .get, headers: headers).responseJSON { (response) in
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				if let lastSynch = dict["created_at"] as? String {
					self.lastSynch = lastSynch
				}
			}
			completed()
		}
	}
	
}
