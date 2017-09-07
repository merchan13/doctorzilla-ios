//
//  MedicalRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/24/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import ReachabilitySwift
import RealmSwift

class MedicalRecordVC: UIViewController {
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var detailView: UIView!
	@IBOutlet weak var consultationView: UIView!
	@IBOutlet weak var operativeNoteView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var detailVC: RecordDetailVC!
	var consultationVC: ConsultationsVC!
	var noteVC: OperativeNotesVC!

	let realm = try! Realm()
	let sync = Synchronize()
	var rMedrecord: RMedicalRecord!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.detailVC.rMedrecord = rMedrecord
		self.consultationVC.rMedrecord = rMedrecord
		self.noteVC.rMedrecord = rMedrecord
		
		self.detailVC.setDetails()
		self.consultationVC.setDetails()
		self.noteVC.setDetails()
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? RecordDetailVC, segue.identifier == "RecordDetailVC" {
			self.detailVC = vc
		}
		if let vc = segue.destination as? ConsultationsVC, segue.identifier == "ConsultationsVC" {
			self.consultationVC = vc
		}
		if let vc = segue.destination as? OperativeNotesVC, segue.identifier == "OperativeNotesVC" {
			self.noteVC = vc
		}
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func segmentSelected(_ sender: UISegmentedControl) {
	
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			detailView.isHidden = false
			consultationView.isHidden = true
			operativeNoteView.isHidden = true
			break
		case 1:
			detailView.isHidden = true
			consultationView.isHidden = false
			operativeNoteView.isHidden = true
			break
		case 2:
			detailView.isHidden = true
			consultationView.isHidden = true
			operativeNoteView.isHidden = false
			break
		default:
			break
		}
		
	}
	
	
	func recoveredNetworkData() {
		let syncAlert = UIAlertController(title: "ALERTA", message: "Se ha recupero la conexión a internet, se recomienda que sincronice los datos antes de seguir.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Sincronizar", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				self.activityIndicator.startAnimating()
			}
			
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			
			self.sync.synchronizeDatabases(user: user, completed: {
				
				self.detailVC.setDetails()
				self.consultationVC.setDetails()
				//self.noteVC.setDetails()
				
				DispatchQueue.main.async {
					self.activityIndicator.stopAnimating()
				}
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido sincronizados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
					
				}))
				
				self.present(successAlert, animated: true, completion: nil)
			})
		}))
		
		syncAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			print("Sync Canceled")
		}))
		
		self.present(syncAlert, animated: true, completion: nil)
	}

}

extension MedicalRecordVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		if status == .notReachable {
			let successAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Actualmente no posee conexión a internet.\n\nSe advierte que es posible que trabaje con información desactualizada.", preferredStyle: UIAlertControllerStyle.alert)
			
			successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(successAlert, animated: true, completion: nil)
		} else {
			self.recoveredNetworkData()
		}
	}
}
