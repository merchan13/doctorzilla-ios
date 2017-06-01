//
//  ConsultationDetailVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/30/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ConsultationDetailVC: UIViewController {

	@IBOutlet weak var reasonLabel: UILabel!
	@IBOutlet weak var afflictionTextView: UITextView!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heightLabel: UILabel!
	@IBOutlet weak var IMCLabel: UILabel!
	@IBOutlet weak var pressureLabel: UILabel!
	@IBOutlet weak var backgroundCollection: UICollectionView!
	@IBOutlet weak var PECollection: UICollectionView!
	@IBOutlet weak var evolutionTextView: UITextView!
	@IBOutlet weak var noteTextView: UITextView!
	@IBOutlet weak var diagnosticTextView: UITextView!
	@IBOutlet weak var planTextView: UITextView!
	
	var consultation: Consultation!
	
	var backgrounds = [Background]()
	var physicalExams = [PhysicalExam]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.consultation.downloadConsultationDetails {
			self.updateUI()
		}
    }
	
	func updateUI() {
		self.reasonLabel.text = self.consultation.reason
		self.afflictionTextView.text = self.consultation.affliction
		self.weightLabel.text = "\(self.consultation.weight)"
		self.heightLabel.text = "\(self.consultation.height)"
		self.IMCLabel.text = "\(self.consultation.IMC())"
		self.pressureLabel.text = "\(self.consultation.pressure_s)/\(self.consultation.pressure_d)"
		// Background Collection
		// PE Collection
		self.evolutionTextView.text = self.consultation.evolution
		self.noteTextView.text = self.consultation.note
		self.diagnosticTextView.text = self.consultation.diagnostic
		self.planTextView.text = self.consultation.plan
	}
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
