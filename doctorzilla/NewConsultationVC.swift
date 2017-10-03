//
//  NewConsultationVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 10/2/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class NewConsultationVC: UITableViewController, UITextViewDelegate {

	@IBOutlet weak var note: UITextView!
	
	var rMedrecord: RMedicalRecord!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let synchronizer = Synchronize()
	
	
	override func viewDidLoad() {
		
        super.viewDidLoad()
		
		self.note.delegate = self
    }

	@IBAction func saveConsultationButtonTapped(_ sender: UIButton) {
		
		let refreshAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere guardar una nueva Consulta Médica?", preferredStyle: UIAlertControllerStyle.alert)
		
		refreshAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			try! self.realm.write {
			
				let rConsultation = RConsultation()
				
				rConsultation.note = self.note.text
				
				rConsultation.recordId = self.rMedrecord.id
				
				rConsultation.date = Date().iso8601
				
				self.rMedrecord.lastUpdate = rConsultation.date.dateFromISO8601!
				
				self.realm.add(rConsultation, update: true)
				
				self.rMedrecord.consultations.append(rConsultation)
				
				self.checkNetwork()
				
				if NetworkConnection.sharedInstance.haveConnection {
					
					self.dataHelper.createConsultation(consultation: rConsultation, completed: {
						
						self.navigationController?.popViewController(animated: true)
					})
				}
				else {
					
					self.navigationController?.popViewController(animated: true)
				}
			}
		}))
		
		refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			
			print("Creation canceled")
		}))
		
		present(refreshAlert, animated: true, completion: nil)
	}
	
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		if(text == "\n") {
			
			textView.resignFirstResponder()
			note.resignFirstResponder()
			
			return false
		}
		
		return true
	}
}
