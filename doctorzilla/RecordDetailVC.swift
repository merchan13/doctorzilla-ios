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
	@IBOutlet weak var referredByLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heigthLabel: UILabel!
	@IBOutlet weak var IMCLabel: UILabel!
	@IBOutlet weak var pressureLabel: UILabel!
	@IBOutlet weak var backgroundCollection: UICollectionView!
	
	var rMedrecord: RMedicalRecord!
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
		
		checkNetwork()
		
		self.updateUIRLM()
		
	}
	
	func updateUIRLM() {
		profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
		fullNameLabel.text = "\(self.rMedrecord.name) \(self.rMedrecord.lastName)"
		documentLabel.text = self.rMedrecord.document
		birthdayLabel.text = "\(self.rMedrecord.parsedBirthdayDate()) (\(self.rMedrecord.age()) años)"
		firstConsultationLabel.text = self.rMedrecord.parsedFirstConsultationDate()
		occupationLabel.text = self.rMedrecord.occupation?.name
		emailLabel.text = self.rMedrecord.email
		phoneLabel.text = self.rMedrecord.phone
		cellphoneLabel.text = self.rMedrecord.cellphone
		insuranceLabel.text = self.rMedrecord.insurance?.name
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
			bg = self.rMedrecord.backgroundsArray()[indexPath.row]
			cell.configureCell(bg)
			
			return cell
		} else {
			return UICollectionViewCell()
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.rMedrecord.backgroundsArray().count
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
