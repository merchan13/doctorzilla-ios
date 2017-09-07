//
//  OperativeNotesVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/25/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class OperativeNotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	
	var rMedrecord: RMedicalRecord!
	var sortedNotes = [ROperativeNote]()
	let realm = try! Realm()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.tableView.indexPathForSelectedRow{
			
			self.tableView.deselectRow(at: index, animated: true)
		}
	}
	
	
	func setDetails() {
		
		let consultations = self.rMedrecord.consultations
		
		for consultation in consultations {
			
			if let plan = consultation.plan {
				
				if let opNote = plan.operativeNote {
					
					self.sortedNotes.append(opNote)
				}
			}
		}
		
		self.sortedNotes.sort(by: { $0.date > $1.date })
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "OperativeNoteCell", for: indexPath) as? OperativeNoteCell {
			
			let rOperativeNote = self.sortedNotes[indexPath.row]
			
			cell.configureCell(rOperativeNote: rOperativeNote)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.sortedNotes.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let rOperativeNote = self.sortedNotes[indexPath.row]
		performSegue(withIdentifier: "ShowOperativeNoteVC", sender: rOperativeNote)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ShowOperativeNoteVC, segue.identifier == "ShowOperativeNoteVC" {
			if let rOperativeNote = sender as? ROperativeNote {
				vc.rOperativeNote = rOperativeNote
			}
		}
	}
	
}
