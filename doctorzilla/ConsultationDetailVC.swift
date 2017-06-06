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
		
		backgroundCollection.dataSource = self
		PECollection.dataSource = self
		
		backgroundCollection.delegate = self
		PECollection.delegate = self
		
		self.consultation.downloadConsultationDetails {
			self.updateUI()
			
			self.backgrounds = self.consultation.backgrounds
			self.physicalExams = self.consultation.physicalExams
			
			self.backgroundCollection.reloadData()
			self.PECollection.reloadData()
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
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == self.backgroundCollection {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
			
				let bg: Background!
				bg = backgrounds[indexPath.row]
				cell.configureCell(bg)
			
				return cell
			}
		} else {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PECell", for: indexPath) as? PECell {
				
				let pe: PhysicalExam!
				pe = physicalExams[indexPath.row]
				cell.configureCell(pe)
				
				return cell
			}
		}
		
		return UICollectionViewCell()
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.backgroundCollection {
			return backgrounds.count
		}
		
		return physicalExams.count
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
