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

class RecordDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

	@IBOutlet weak var fullNameLabel: UILabel!
	@IBOutlet weak var documentLabel: UILabel!
	@IBOutlet weak var birthdayLabel: UILabel!
	@IBOutlet weak var firstConsultationLabel: UILabel!
	@IBOutlet weak var occupationLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var phoneLabel: UILabel!
	@IBOutlet weak var cellphoneLabel: UILabel!
	@IBOutlet weak var insuranceLabel: UILabel!
	@IBOutlet weak var referredByLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heigthLabel: UILabel!
	@IBOutlet weak var IMCLabel: UILabel!
	@IBOutlet weak var pressureLabel: UILabel!
	@IBOutlet weak var backgroundCollection: UICollectionView!
	
	var medrecord: MedicalRecord!
	var backgrounds = [Background]()
	let realm = try! Realm()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		setDetails()
	}
	
	func setDetails() {
		backgroundCollection.dataSource = self
		backgroundCollection.delegate = self
		
		self.medrecord.downloadRecordDetails {
			self.updateUI()
			self.backgrounds = self.medrecord.backgroundsArray()
			self.backgroundCollection.reloadData()
			
			// Save to Realm
			try! self.realm.write {
				let rMedRecord = RMedicalRecord()
				rMedRecord.id = self.medrecord.recordId
				rMedRecord.document = self.medrecord.document
				rMedRecord.name = self.medrecord.name
				rMedRecord.lastName = self.medrecord.lastName
				rMedRecord.birthday = self.medrecord.birthday
				rMedRecord.firstConsultation = self.medrecord.firstConsultation
				rMedRecord.email = self.medrecord.email
				rMedRecord.phone = self.medrecord.phone
				rMedRecord.cellphone = self.medrecord.cellphone
				rMedRecord.address = self.medrecord.address
				rMedRecord.gender = self.medrecord.gender
				rMedRecord.referredBy = self.medrecord.referredBy
				rMedRecord.height = self.medrecord.height
				rMedRecord.weight = self.medrecord.weight
				rMedRecord.pressure_d = self.medrecord.pressure_d
				rMedRecord.pressure_s = self.medrecord.pressure_s
				rMedRecord.lastUpdate = self.medrecord.lastUpdate
				self.realm.add(rMedRecord, update: true)
			}
		}
	}
	
	func updateUI() {
		fullNameLabel.text = "\(self.medrecord.name) \(self.medrecord.lastName)"
		documentLabel.text = self.medrecord.document
		birthdayLabel.text = "\(self.medrecord.parsedBirthdayDate()) (\(self.medrecord.age()) años)"
		firstConsultationLabel.text = self.medrecord.parsedFirstConsultationDate()
		occupationLabel.text = self.medrecord.occupation
		emailLabel.text = self.medrecord.email
		phoneLabel.text = self.medrecord.phone
		cellphoneLabel.text = self.medrecord.cellphone
		insuranceLabel.text = self.medrecord.insurance
		referredByLabel.text = self.medrecord.referredBy
		weightLabel.text = "\(self.medrecord.weight) kg."
		heigthLabel.text = "\(self.medrecord.height) m."
		IMCLabel.text = "\(self.medrecord.IMC())"
		pressureLabel.text = "\(self.medrecord.pressure_s)/\(self.medrecord.pressure_d)"
	}
	
	@IBAction func editButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: "EditRecordVC", sender: self.medrecord)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditRecordVC" {
			if let editRecordVC = segue.destination as? EditRecordVC {
				if let medrec = sender as? MedicalRecord {
					editRecordVC.medrecord = medrec
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
			
			let bg: Background!
			bg = backgrounds[indexPath.row]
			cell.configureCell(bg)
			
			return cell
		} else {
			return UICollectionViewCell()
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return backgrounds.count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 285, height: 100)
	}
	
}

extension RecordDetailVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		switch status {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
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
