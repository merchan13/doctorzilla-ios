//
//  RecordDetailVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class RecordDetailVC: UIViewController {

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
	@IBOutlet weak var familyBgTextView: UITextView!
	@IBOutlet weak var allergyBgTextView: UITextView!
	@IBOutlet weak var diabetesBgTextView: UITextView!
	@IBOutlet weak var asthmaBgTextView: UITextView!
	@IBOutlet weak var heartBgTextView: UITextView!
	@IBOutlet weak var medicineBgTextView: UITextView!
	@IBOutlet weak var surgicalBgTextView: UITextView!
	@IBOutlet weak var otherBgTextView: UITextView!
	
	var medrecord: MedicalRecord!
	var backgrounds: [String: String]!
	
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
		
		self.backgrounds = self.medrecord.backgrounds
		
		familyBgTextView.text = self.backgrounds["Familiares"]
		allergyBgTextView.text = self.backgrounds["Alergias"]
		diabetesBgTextView.text = self.backgrounds["Diábetes"]
		asthmaBgTextView.text = self.backgrounds["Asma"]
		heartBgTextView.text = self.backgrounds["Cardiopatías"]
		medicineBgTextView.text = self.backgrounds["Medicinas"]
		surgicalBgTextView.text = self.backgrounds["Quirúrgicos"]
		otherBgTextView.text = self.backgrounds["Otros"]
	}
	
}
