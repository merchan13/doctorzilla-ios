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

	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var document: UILabel!
	@IBOutlet weak var birthday: UILabel!
	@IBOutlet weak var firstConsultation: UILabel!
	@IBOutlet weak var occupation: UILabel!
	@IBOutlet weak var phoneNumber: UILabel!
	@IBOutlet weak var cellphoneNumber: UILabel!
	@IBOutlet weak var email: UILabel!
	@IBOutlet weak var insurance: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var referredBy: UILabel!
	@IBOutlet weak var weight: UILabel!
	@IBOutlet weak var height: UILabel!
	@IBOutlet weak var imc: UILabel!
	@IBOutlet weak var pressure: UILabel!
	
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
		self.diagnosticsTable.delegate = self
		self.diagnosticsTable.dataSource = self
		
		self.backgroundsTable.delegate = self
		self.backgroundsTable.dataSource = self
		
		self.attachmentsTable.delegate = self
		self.attachmentsTable.dataSource = self
		*/
		self.updateUI()
	}
	
	
	func updateUI() {
		
		checkNetwork()
		
		/*
		if self.rMedrecord.profilePic.length == 0 {
		
			// si hay senal descargar, sino no hacer nada
			self.dataHelper.downloadProfilePicture(rec: self.rMedrecord, completed: {
				self.profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
			})
		} else {
			profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
		}
		*/
		
		name.text = "\(self.rMedrecord.name) \(self.rMedrecord.lastName)"
		
		document.text = self.rMedrecord.document
		
		birthday.text = "\(self.rMedrecord.parsedBirthdayDate()) (\(self.rMedrecord.age()) años)"
		
		firstConsultation.text = self.rMedrecord.parsedFirstConsultationDate()
		
		occupation.text = self.rMedrecord.occupation?.name
		
		email.text = self.rMedrecord.email
		
		phoneNumber.text = self.rMedrecord.phone
		
		cellphoneNumber.text = self.rMedrecord.cellphone
		
		insurance.text = self.rMedrecord.insurance?.name
		
		address.text = self.rMedrecord.address
		
		referredBy.text = self.rMedrecord.referredBy
		
		weight.text = "\(self.rMedrecord.weight) kg."
		
		height.text = "\(self.rMedrecord.height) m."
		
		imc.text = "\(self.rMedrecord.IMC())"
		
		pressure.text = "\(self.rMedrecord.pressure_s)/\(self.rMedrecord.pressure_d)"
		
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
		else if segue.identifier == "ShowRecordBackgroundsVC" {
			
			if let showRecordBgVC = segue.destination as? ShowRecordBackgroundsVC {
				
				if let rBackgrounds = sender as? List<RBackground> {
					
					showRecordBgVC.rBackgrounds = rBackgrounds
				}
			}
		}
		else if segue.identifier == "ShowRecordDiagnosticsVC" {
			
			if let showRecordDxVC = segue.destination as? ShowRecordDiagnosticsVC {
				
				if let rDiagnostics = sender as? List<RDiagnostic> {
					
					showRecordDxVC.rDiagnostics = rDiagnostics
				}
			}
		}
		else if segue.identifier == "ShowRecordAttachmentsVC" {
			
			if let showRecordAttchVC = segue.destination as? ShowRecordAttachmentsVC {
				
				if let rAttachments = sender as? List<RAttachment> {
					
					showRecordAttchVC.rAttachments = rAttachments
				}
			}
		}
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 1 {
			
			if indexPath.row == 4 {
				
				performSegue(withIdentifier: "ShowRecordBackgroundsVC", sender: self.rMedrecord.backgrounds)
			}
			else if indexPath.row == 5 {
				
				performSegue(withIdentifier: "ShowRecordDiagnosticsVC", sender: self.rMedrecord.diagnostics())
			}
			else if indexPath.row == 6 {
			
				performSegue(withIdentifier: "ShowRecordAttachmentsVC", sender: self.rMedrecord.attachments)
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
