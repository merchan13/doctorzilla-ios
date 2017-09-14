//
//  ShowRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/14/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift
import SafariServices

class ShowRecordVC: UITableViewController {

	var rMedrecord: RMedicalRecord!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	var networkConnection = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
		
		self.setDetails {
			
			//if let index = self.attachmentsTableView.indexPathForSelectedRow{
				
			//	self.attachmentsTableView.deselectRow(at: index, animated: true)
			//}
		}
	}
	
	
	func setDetails(completed: @escaping DownloadComplete) {
		/*
		backgroundCollection.dataSource = self
		backgroundCollection.delegate = self
		
		self.attachmentsTableView.delegate = self
		self.attachmentsTableView.dataSource = self
		
		self.updateUI()
		*/
	}
	
	
	func updateUI() {
		/*
		if self.rMedrecord.profilePic.length == 0 {
			self.dataHelper.downloadProfilePicture(rec: self.rMedrecord, completed: {
				self.profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
			})
		} else {
			profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
		}
		fullNameLabel.text = "\(self.rMedrecord.name) \(self.rMedrecord.lastName)"
		documentLabel.text = self.rMedrecord.document
		birthdayLabel.text = "\(self.rMedrecord.parsedBirthdayDate()) (\(self.rMedrecord.age()) años)"
		firstConsultationLabel.text = self.rMedrecord.parsedFirstConsultationDate()
		occupationLabel.text = self.rMedrecord.occupation?.name
		emailLabel.text = self.rMedrecord.email
		phoneLabel.text = self.rMedrecord.phone
		cellphoneLabel.text = self.rMedrecord.cellphone
		insuranceLabel.text = self.rMedrecord.insurance?.name
		addressLabel.text = self.rMedrecord.address
		referredByLabel.text = self.rMedrecord.referredBy
		weightLabel.text = "\(self.rMedrecord.weight) kg."
		heigthLabel.text = "\(self.rMedrecord.height) m."
		IMCLabel.text = "\(self.rMedrecord.IMC())"
		pressureLabel.text = "\(self.rMedrecord.pressure_s)/\(self.rMedrecord.pressure_d)"
		*/
	}
	
	
	@IBAction func editButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: "EditRecordVC", sender: self.rMedrecord)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditRecordVC" {
			if let editRecordVC = segue.destination as? EditRecordVC {
				if let rMedrec = sender as? RMedicalRecord {
					editRecordVC.rMedrecord = rMedrec
				}
			}
		}
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 0 {
			
			if indexPath.row == 0 {
				
			}
		}
		else if indexPath.section == 1 {
			
			if indexPath.row == 0 {
				
				
			} else if indexPath.row == 1 {
				
			}
		}
	}

	
	func recoveredNetworkData() {
		/*
		let syncAlert = UIAlertController(title: "ALERTA", message: "Se ha recupero la conexión a internet, se recomienda que sincronice los datos antes de seguir.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Sincronizar", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				//self.activityIndicator.startAnimating()
			}
			
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			
			self.sync.synchronizeDatabases(user: user, completed: {
				
				self.setDetails {
					self.backgroundCollection.reloadData()
					self.attachmentsTableView.reloadData()
				}
				
				DispatchQueue.main.async {
					//self.activityIndicator.stopAnimating()
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
		*/
	}
	
}

extension ShowRecordVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		if status == .notReachable {
			let successAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Actualmente no posee conexión a internet.\n\nSe advierte que es posible que trabaje con información desactualizada.", preferredStyle: UIAlertControllerStyle.alert)
			
			successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(successAlert, animated: true, completion: nil)
		} else {
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
