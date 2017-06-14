//
//  MedicalRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/24/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class MedicalRecordVC: UIViewController {
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var detailView: UIView!
	@IBOutlet weak var consultationView: UIView!
	@IBOutlet weak var operativeNoteView: UIView!
	
	var detailVC: RecordDetailVC!
	var consultationVC: ConsultationsVC!
	var noteVC: OperativeNotesVC!
	
	var medrecord: MedicalRecord!
	var rMedrecord: RMedicalRecord!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.detailVC.medrecord = medrecord
		self.consultationVC.medrecord = medrecord
		//self.noteVC.medrecord = medrecord
		
		self.detailVC.rMedrecord = rMedrecord
		self.consultationVC.rMedrecord = rMedrecord
		//self.noteVC.rMedrecord = rMedrecord
		
		self.detailVC.setDetails()
		self.consultationVC.setDetails()
		//self.noteVC.setDetails()
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? RecordDetailVC, segue.identifier == "RecordDetailVC" {
			self.detailVC = vc
		}
		if let vc = segue.destination as? ConsultationsVC, segue.identifier == "ConsultationsVC" {
			self.consultationVC = vc
		}
		if let vc = segue.destination as? OperativeNotesVC, segue.identifier == "OperativeNotesVC" {
			self.noteVC = vc
		}
	}
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func segmentSelected(_ sender: UISegmentedControl) {
	
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			detailView.isHidden = false
			consultationView.isHidden = true
			operativeNoteView.isHidden = true
			break
		case 1:
			detailView.isHidden = true
			consultationView.isHidden = false
			operativeNoteView.isHidden = true
			break
		case 2:
			detailView.isHidden = true
			consultationView.isHidden = true
			operativeNoteView.isHidden = false
			break
		default:
			break
		}
		
	}

}
