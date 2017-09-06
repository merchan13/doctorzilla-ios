//
//  ConsultationsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ConsultationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	
	var rMedrecord: RMedicalRecord!
	var sortedConsultations: Results<RConsultation>!
	let realm = try! Realm()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.tableView.indexPathForSelectedRow{
			
			self.tableView.deselectRow(at: index, animated: true)
		}
	}
	
	
	func setDetails() {
		
		//self.sortedConsultations = self.rMedrecord.consultations.sorted(byKeyPath: "lastUpdate", ascending: false)
		self.sortedConsultations = self.rMedrecord.consultations.sorted(byKeyPath: "date", ascending: false)
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ConsultationCell", for: indexPath) as? ConsultationCell {
			
			let rConsultation = self.sortedConsultations[indexPath.row]
			
			cell.configureCell(rConsultation: rConsultation)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rMedrecord.consultations.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let rConsultation = self.rMedrecord.consultations[indexPath.row]
		performSegue(withIdentifier: "ConsultationDetailVC", sender: rConsultation)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ConsultationDetailVC, segue.identifier == "ConsultationDetailVC" {
			if let rConsultation = sender as? RConsultation {
				vc.rConsultation = rConsultation
			}
		}
	}
	
}
