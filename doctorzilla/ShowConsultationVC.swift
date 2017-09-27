//
//  ShowConsultationVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/27/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ShowConsultationVC: UITableViewController {

	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var reason: UILabel!
	@IBOutlet weak var affliction: UILabel!
	@IBOutlet weak var weight: UILabel!
	@IBOutlet weak var height: UILabel!
	@IBOutlet weak var pressure: UILabel!
	@IBOutlet weak var imc: UILabel!
	@IBOutlet weak var physicalExamsButton: UILabel!
	@IBOutlet weak var evolution: UITextView!
	@IBOutlet weak var notes: UITextView!
	@IBOutlet weak var diagnosticsButton: UILabel!
	@IBOutlet weak var plan: UITextView!
	
	var rConsultation: RConsultation!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	var networkConnection = false
	
	
    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.updateUI()
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		//...
	}
	
	
	func updateUI() {
		
		self.date.text = "Consulta [\(self.rConsultation.parsedConsultationDate())]"
		
		self.reason.text = self.rConsultation.reason?.reasonDescription
		
		self.affliction.text = self.rConsultation.affliction.isEmpty
			? "N/A"
			: self.rConsultation.affliction
		
		self.weight.text = self.rConsultation.weight == 0
			? "N/A"
			: "\(self.rConsultation.weight)kg"
		
		self.height.text = self.rConsultation.height == 0
			? "N/A"
			: "\(Float(self.rConsultation.height)/100)m"
		
		self.imc.text =  self.rConsultation.IMC() == 0
			? "N/A"
			: "\(self.rConsultation.IMC())"
		
		self.pressure.text =  (self.rConsultation.pressure_s.isEmpty || self.rConsultation.pressure_d.isEmpty)
			? "N/A"
			: "\(self.rConsultation.pressure_s)/\(self.rConsultation.pressure_d)"
		
		self.evolution.text = self.rConsultation.evolution.isEmpty
			? "N/A"
			: self.rConsultation.evolution
		
		self.notes.text = self.rConsultation.note.isEmpty
			? "N/A"
			: self.rConsultation.note
		
		self.plan.text = (self.rConsultation.plan?.planDescription.isEmpty)!
			? "N/A"
			: self.rConsultation.plan?.planDescription
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "EditConsultationVC" {
			
			if let editRecordVC = segue.destination as? EditRecordVC {
				
				if let rMedrec = sender as? RMedicalRecord {
					
					editRecordVC.rMedrecord = rMedrec
				}
			}
		}
		else if segue.identifier == "ShowConsultationDiagnosticsVC" {
			
			if let showRecordDxVC = segue.destination as? ShowRecordDiagnosticsVC {
				
				if let rDiagnostics = sender as? [RDiagnostic] {
					
					showRecordDxVC.rDiagnostics = rDiagnostics
				}
			}
		}
		else if segue.identifier == "ShowConsultationPEVC" {
			
			if let showRecordBgVC = segue.destination as? ShowRecordBackgroundsVC {
				
				if let rBackgrounds = sender as? List<RBackground> {
					
					showRecordBgVC.rBackgrounds = rBackgrounds
				}
			}
		}
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 3 {
			
			if indexPath.row == 0 {
				
				print("Examenes!")
				//performSegue(withIdentifier: "IndexConsultationsVC", sender: self.rMedrecord.consultations)
			}
		}
		else if indexPath.section == 6 {
			
			if indexPath.row == 0 {
				
				print("Diagnosticos!")
				//performSegue(withIdentifier: "IndexConsultationsVC", sender: self.rMedrecord.consultations)
			}
		}
	}
	
	
	func recoveredNetworkData() {
		//
	}

}

extension ShowConsultationVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		
		if status == .notReachable {
			
			let successAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Actualmente no posee conexión a internet.\n\nSe advierte que es posible que trabaje con información desactualizada.", preferredStyle: UIAlertControllerStyle.alert)
			
			successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(successAlert, animated: true, completion: nil)
		}
		else {
			
			networkConnection = true
			
			self.recoveredNetworkData()
		}
	}
	
	func checkNetwork() {
		switch ReachabilityManager.shared.reachability.currentReachabilityStatus {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
	
}
