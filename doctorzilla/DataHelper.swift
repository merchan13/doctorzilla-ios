//
//  DataHelper.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/5/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import Alamofire

class DataHelper {
	
	private var _occupations = [Occupation]()
	private var _insurances = [Insurance]()
	
	var occupations: [Occupation] {
		return _occupations
	}
	
	var insurances: [Insurance] {
		return _insurances
	}
	
	func downloadOccupations(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_OCCUPATIONS)", method: .get, headers: headers).responseJSON { (response) in
			self._occupations.removeAll()
			if let occupationsArray = response.result.value as? [Dictionary<String, AnyObject>] {
				// OCCUPATIONS
				for occupationDict in occupationsArray {
					self._occupations.append(Occupation(occupationId: occupationDict["id"] as! Int, name: occupationDict["name"] as! String))
				}
			}
			completed()
		}
		
	}
	
	func downloadInsurances(completed: @escaping DownloadComplete) {
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request("\(URL_BASE)\(URL_INSURANCES)", method: .get, headers: headers).responseJSON { (response) in
			self._insurances.removeAll()
			if let insurancesArray = response.result.value as? [Dictionary<String, AnyObject>] {
				// INSURANCES
				for insuranceDict in insurancesArray {
					self._insurances.append(Insurance(insuranceId: insuranceDict["id"] as! Int, name: insuranceDict["name"] as! String))
				}
			}
			completed()
		}
		
	}

}
