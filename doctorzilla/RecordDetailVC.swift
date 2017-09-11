//
//  RecordDetailVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift
import SafariServices

class RecordDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var profilePictureImage: UIImageView!
	@IBOutlet weak var fullNameLabel: UILabel!
	@IBOutlet weak var documentLabel: UILabel!
	@IBOutlet weak var birthdayLabel: UILabel!
	@IBOutlet weak var firstConsultationLabel: UILabel!
	@IBOutlet weak var occupationLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var phoneLabel: UILabel!
	@IBOutlet weak var cellphoneLabel: UILabel!
	@IBOutlet weak var insuranceLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var referredByLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heigthLabel: UILabel!
	@IBOutlet weak var IMCLabel: UILabel!
	@IBOutlet weak var pressureLabel: UILabel!
	@IBOutlet weak var backgroundCollection: UICollectionView!
	@IBOutlet weak var attachmentsTableView: UITableView!
	
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
			
			if let index = self.attachmentsTableView.indexPathForSelectedRow{
				
				self.attachmentsTableView.deselectRow(at: index, animated: true)
			}
		}
	}
	
	
	func setDetails(completed: @escaping DownloadComplete) {
		backgroundCollection.dataSource = self
		backgroundCollection.delegate = self
		
		self.attachmentsTableView.delegate = self
		self.attachmentsTableView.dataSource = self
		
		self.updateUI()
	}
	
	
	func updateUI() {
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
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
			let bg: RBackground!
			bg = self.rMedrecord.backgrounds[indexPath.row]
			cell.configureCell(bg)
			
			return cell
		} else {
			return UICollectionViewCell()
		}
		
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.rMedrecord.backgrounds.count
	}
	
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 285, height: 100)
	}
	

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath) as? AttachmentCell {
			
			let rAttachment = self.rMedrecord.attachments[indexPath.row]
			
			cell.configureCell(rAttachment: rAttachment)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rMedrecord.attachments.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		checkNetwork()
		
		if self.networkConnection {
			
			let rAttachment = self.rMedrecord.attachments[indexPath.row]
			
			self.dataHelper.downloadAttachmentURL(id: rAttachment.id) { (result: String) in
				
				let svc = SFSafariViewController(url: URL(string: result)!)
				
				self.present(svc, animated: true, completion: nil)
			}
		}
		else {
			
			let cantShowAttachmentAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Los anexos solo pueden ser vistos con conexión a internet.", preferredStyle: UIAlertControllerStyle.alert)
			
			cantShowAttachmentAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(cantShowAttachmentAlert, animated: true, completion: nil)
		}
	}
	
	
	func recoveredNetworkData() {
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
	}
	
}

extension RecordDetailVC: NetworkStatusListener {
	
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
