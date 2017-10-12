//
//  ActivitiesVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import RealmSwift

class ActivitiesVC: UITableViewController {

	@IBOutlet weak var records_count: UILabel!
	@IBOutlet weak var consultations_count: UILabel!
	@IBOutlet weak var procedures_count: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        print("ActivitiesVC")
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		checkNetwork()
		
		if NetworkConnection.sharedInstance.haveConnection {
			
			self.activitiesReport {
				
				print("Actividades descargadas")
			}
		}
		else {
			
			self.records_count.text = "Para actualizar esta información se necesita conexión a Internet"
			self.consultations_count.text = "Para actualizar esta información se necesita conexión a Internet"
			self.procedures_count.text = "Para actualizar esta información se necesita conexión a Internet"
		}
	}
	
	func activitiesReport(completed: @escaping DownloadComplete) {
		
		let activitiesURL = "\(URL_BASE)\(URL_ACTIVITIES)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		
		Alamofire.request(activitiesURL, method: .get, headers: headers).responseJSON { (response) in
			
			if let dict = response.result.value as? Dictionary<String, AnyObject> {
				
				if let records = dict["records_total"] as? Int {
					
					self.records_count.text = "\(records) historias"
				}
				
				if let consultations = dict["consultations_total"] as? Int {
					
					self.consultations_count.text = "\(consultations) consultas"
				}
				
				if let procedures = dict["procedures_total"] as? Int {
					
					self.procedures_count.text = "\(procedures) operaciones"
				}
			}
			
			completed()
		}
	}

}
