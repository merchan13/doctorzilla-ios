//
//  ShowOperativeNoteVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/6/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift

class ShowOperativeNoteVC: UIViewController {

	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var planDescriptionLabel: UILabel!
	@IBOutlet weak var proceduresLabel: UILabel!
	@IBOutlet weak var findsLabel: UILabel!
	@IBOutlet weak var noteDescriptionLabel: UILabel!
	@IBOutlet weak var diagnosticLabel: UILabel!
	
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
		
		self.dateLabel.text = "Consulta [\(self.rOperativeNote.parsedCreationDate())]"
		self.planDescriptionLabel.text = planDescription
		self.proceduresLabel.text = parsedProcedures
		self.findsLabel.text = self.rOperativeNote.find
		self.noteDescriptionLabel.text = self.rOperativeNote.opNoteDescription
		self.diagnosticLabel.text = self.rOperativeNote.diagnostic
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}

}
