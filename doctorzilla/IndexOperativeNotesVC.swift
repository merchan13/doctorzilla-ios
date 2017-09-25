//
//  IndexOperativeNotesVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/24/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class IndexOperativeNotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var notesTable: UITableView!
	
	var rOperativeNotes: [ROperativeNote]!
	let realm = try! Realm()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.notesTable.delegate = self
		self.notesTable.dataSource = self
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.notesTable.indexPathForSelectedRow{
			
			self.notesTable.deselectRow(at: index, animated: true)
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "OperativeNoteCell", for: indexPath) as? OperativeNoteCell {
			
			let rOperativeNote = self.rOperativeNotes[indexPath.row]
			
			cell.configureCell(rOperativeNote: rOperativeNote)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rOperativeNotes.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let rOperativeNote = self.rOperativeNotes[indexPath.row]
		
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
