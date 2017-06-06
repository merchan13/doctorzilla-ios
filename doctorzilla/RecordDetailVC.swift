//
//  RecordDetailVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

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
