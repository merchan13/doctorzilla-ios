//
//  ConsultationDetailVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/30/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ConsultationDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

	@IBOutlet weak var dateLabel: UILabel!
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
	
	var rConsultation: RConsultation!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		backgroundCollection.dataSource = self
		backgroundCollection.delegate = self
		
		PECollection.dataSource = self
		PECollection.delegate = self
		
		self.updateUI()
    }
	
	func updateUI() {
		self.dateLabel.text = "Consulta [\(self.rConsultation.parsedConsultationDate())]"
		self.reasonLabel.text = self.rConsultation.reason?.reasonDescription
		self.afflictionTextView.text = self.rConsultation.affliction
		self.weightLabel.text = "\(self.rConsultation.weight)"
		self.heightLabel.text = "\(self.rConsultation.height)"
		self.IMCLabel.text = "\(self.rConsultation.IMC())"
		self.pressureLabel.text = "\(self.rConsultation.pressure_s)/\(self.rConsultation.pressure_d)"
		self.evolutionTextView.text = self.rConsultation.evolution
		self.noteTextView.text = self.rConsultation.note
		self.diagnosticTextView.text = self.rConsultation.diagnostic?.diagnosticDescription
		self.planTextView.text = self.rConsultation.plan?.planDescription
	}
	
	@IBAction func editButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: "EditConsultationVC", sender: self.rConsultation)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditConsultationVC" {
			if let editConsultationVC = segue.destination as? EditConsultationVC {
				if let rConsultation = sender as? RConsultation {
					editConsultationVC.rConsultation = rConsultation
				}
			}
		}
	}
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == self.backgroundCollection {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
				let bg: RBackground!
				bg = self.rConsultation.backgrounds[indexPath.row]
				cell.configureCell(bg)
			
				return cell
			}
		} else {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PECell", for: indexPath) as? PECell {
				let pe: RPhysicalExam!
				pe = self.rConsultation.physicalExams[indexPath.row]
				cell.configureCell(pe)
				
				return cell
			}
		}
		
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.backgroundCollection {
			return self.rConsultation.backgrounds.count
		}
		
		return self.rConsultation.physicalExams.count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == self.backgroundCollection {
			return CGSize(width: 277, height: 65)
		}
		
		return CGSize(width: 277, height: 90)
	}
	
}
