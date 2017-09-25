//
//  ShowOperativeNoteVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/6/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift

class ShowOperativeNoteVC: UITableViewController {

	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var planDescription: UITextView!
	@IBOutlet weak var procedures: UITextView!
	@IBOutlet weak var finds: UITextView!
	@IBOutlet weak var descriptionText: UITextView!
	@IBOutlet weak var diagnostic: UITextView!
	
	var rOperativeNote: ROperativeNote!
	let realm = try! Realm()
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		self.updateUI()
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		self.updateUI()
	}
	
	
	func updateUI() {
		
		var planDescription = "N/A"
		var parsedProcedures = "N/A"
		
		if let notePlan = self.realm.object(ofType: RPlan.self, forPrimaryKey: self.rOperativeNote.planId) {
			
			planDescription = notePlan.planDescription
			
			parsedProcedures = ""
			
			for procedure in notePlan.procedures {
				
				if parsedProcedures == "" {
					
					parsedProcedures += "\(procedure.name)"
				}
				else {
					
					parsedProcedures += " - \(procedure.name)"
				}
			}
		}
		
		self.date.text = "Nota Operatoria [\(self.rOperativeNote.parsedCreationDate())]"
		self.planDescription.text = planDescription
		self.procedures.text = parsedProcedures
		self.finds.text = self.rOperativeNote.find
		self.descriptionText.text = self.rOperativeNote.opNoteDescription
		self.diagnostic.text = self.rOperativeNote.diagnostic
	}
}
