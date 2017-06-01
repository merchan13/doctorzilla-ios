//
//  ConsultationsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ConsultationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var medrecord: MedicalRecord!
	var consultations = [Consultation]()
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func setDetails() {
		
		self.medrecord.downloadConsultations {
			self.tableView.delegate = self
			self.tableView.dataSource = self
			
			self.consultations = self.medrecord.consultations
			
			self.tableView.reloadData()
		}
		
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ConsultationCell", for: indexPath) as? ConsultationCell {
		
			let consultation = consultations[indexPath.row]
			
			cell.updateUI(consultation: consultation)
			return cell
			
		} else {
			return UITableViewCell()
		}
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return consultations.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let consultation = consultations[indexPath.row]
		
		performSegue(withIdentifier: "ConsultationDetailVC", sender: consultation)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let vc = segue.destination as? ConsultationDetailVC, segue.identifier == "ConsultationDetailVC" {
			if let consultation = sender as? Consultation {
				vc.consultation = consultation
			}
		}
		
	}

}
