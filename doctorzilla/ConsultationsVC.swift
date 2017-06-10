//
//  ConsultationsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift

class ConsultationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	
	var medrecord: MedicalRecord!
	var consultations = [Consultation]()
	
	let realm = try! Realm()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func setDetails() {
		self.medrecord.downloadConsultations {
			self.tableView.delegate = self
			self.tableView.dataSource = self
			
			self.consultations = self.medrecord.consultations
			
			self.tableView.reloadData()
			
			try! self.realm.write {
				for consultation in self.consultations {
					if self.realm.object(ofType: RConsultation.self, forPrimaryKey: consultation.consultationId) == nil {
						let rConsultation = RConsultation()
						rConsultation.id = consultation.consultationId
						rConsultation.date = consultation.date
						
						var rReason = RReason()
						if consultation.reason != "" {
							if let existingReason = self.realm.object(ofType: RReason.self, forPrimaryKey: consultation.reasonId) {
								rReason = existingReason
							} else {
								rReason.id = consultation.reasonId
								rReason.reasonDescription = consultation.reason
								self.realm.add(rReason, update: true)
							}
						}
						
						self.realm.add(rConsultation, update: true)
						rReason.consultations.append(rConsultation)
					}
				}
			}
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
