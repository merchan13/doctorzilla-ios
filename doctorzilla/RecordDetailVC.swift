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
	
	var medrecord: MedicalRecord!
	var background = [Background]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func setDetails() {
		self.medrecord.downloadRecordDetails {
			self.updateUI()
		}
	}
	
	func updateUI() {
		fullNameLabel.text = "\(self.medrecord.name) \(self.medrecord.lastName)"
		documentLabel.text = self.medrecord.document
		/*
		
		birthdayLabel.text = "\(self.medrecord.birthday) (\(self.medrecord.age) años)"
		
		*/
		birthdayLabel.text = "\(self.medrecord.birthday) (años)"
		firstConsultationLabel.text = self.medrecord.firstConsultation
		occupationLabel.text = self.medrecord.occupation
		emailLabel.text = self.medrecord.email
		phoneLabel.text = self.medrecord.phone
		cellphoneLabel.text = self.medrecord.cellphone
		insuranceLabel.text = self.medrecord.insurance
		referredByLabel.text = self.medrecord.referredBy
		weightLabel.text = "\(self.medrecord.weight) kg."
		heigthLabel.text = "\(self.medrecord.height) m."
		IMCLabel.text = "??"
		pressureLabel.text = "\(self.medrecord.pressure_s)/\(self.medrecord.pressure_d)"
		
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
			
			let bg: Background!
			
			bg = background[indexPath.row]
			
			cell.configureCell(bg)
			
			return cell
			
		} else {
			return UICollectionViewCell()
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// Do nothing
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 8
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 260, height: 50)
	}

}
