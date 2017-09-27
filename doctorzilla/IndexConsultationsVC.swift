//
//  IndexConsultationsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class IndexConsultationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var consultationTable: UITableView!
	
	var rConsultations: List<RConsultation>!
	var sortedConsultations: Results<RConsultation>!
	let realm = try! Realm()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.sortedConsultations = self.rConsultations.sorted(byKeyPath: "date", ascending: false)
		
		self.consultationTable.delegate = self
		self.consultationTable.dataSource = self
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.consultationTable.indexPathForSelectedRow{
			
			self.consultationTable.deselectRow(at: index, animated: true)
		}
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
		
		return self.sortedConsultations.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let rConsultation = self.sortedConsultations[indexPath.row]
		
		performSegue(withIdentifier: "ShowConsultationVC", sender: rConsultation)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let vc = segue.destination as? ShowConsultationVC, segue.identifier == "ShowConsultationVC" {
			
			if let rConsultation = sender as? RConsultation {
				
				vc.rConsultation = rConsultation
			}
		}
	}
}
