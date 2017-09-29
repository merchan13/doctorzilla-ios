//
//  IndexRecordsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift
import ReachabilitySwift

class IndexRecordsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var recordsTable: UITableView!
	
	var rMedrecords = [RMedicalRecord]()
	var rFilteredRecords = [RMedicalRecord]()
	var inSearchMode = false
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	

	override func viewDidLoad() {
		
		super.viewDidLoad()
		print("IndexRecordsVC")
		
		if AuthToken.sharedInstance.token != nil {
			print("[ \(AuthToken.sharedInstance.token!) ]\n")
		}
		
		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.done
		
		self.recordsTable.delegate = self
		self.recordsTable.dataSource = self
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.recordsTable.indexPathForSelectedRow{
			
			self.recordsTable.deselectRow(at: index, animated: true)
		}
		
		parseMedicalRecordsRLM {
			
			self.recordsTable.reloadData()
			
			self.checkNetwork()
			
			if NetworkConnection.sharedInstance.haveConnection {
				
				for rec in self.rMedrecords {
					
					if rec.profilePic.length == 0 {
						
						if rec.profilePicURL.isEmpty {
							
							// pedir url y descargar
						}
						else {
							
							self.dataHelper.downloadProfilePicture(rec: rec, completed: {
								
								self.recordsTable.reloadData()
							})
						}
					}
				}
			}
		}
	}
	
	
	/// Get MedicalRecords data from Realm DB
	//
	func parseMedicalRecordsRLM(completed: @escaping DownloadComplete) {
		
		let recordsRealm = realm.objects(RMedicalRecord.self)
		
		self.rMedrecords.removeAll()
		
		for rec in recordsRealm {
			
			self.rMedrecords.append(rec)
		}
		
		self.rMedrecords.sort(by: { $0.lastUpdate > $1.lastUpdate })
		
		completed()
	}
	
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		view.endEditing(true)
	}
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchBar.text == nil || searchBar.text == "" {
			
			inSearchMode = false
			
			recordsTable.reloadData()
			
			view.endEditing(true)
		} else {
			
			inSearchMode = true
			
			let criteria = searchBar.text!
			
			rFilteredRecords = rMedrecords.filter(
			{
				$0.lastName.lowercased().range(of: criteria.lowercased()) != nil ||
				$0.document.lowercased().range(of: criteria.lowercased()) != nil ||
				$0.name.lowercased().range(of: criteria.lowercased()) != nil
			})
			
			recordsTable.reloadData()
		}
	}
	
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		
		checkNetwork()
		
		if NetworkConnection.sharedInstance.haveConnection && !searchBar.text!.isEmpty && searchBar.text!.count > 3 {
			
			inSearchMode = true
			
			self.dataHelper.searchRecord(search: searchBar.text!, completion: { (result: [RMedicalRecord]) in
				
				self.rFilteredRecords = result
				
				self.recordsTable.reloadData()
			})
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalRecordCell", for: indexPath) as? MedicalRecordCell {
			
			let rMedRec: RMedicalRecord!
			
			if inSearchMode {
				
				rMedRec = rFilteredRecords[indexPath.row]
				cell.configureCell(rMedicalRecord: rMedRec)
			}
			else {
				
				rMedRec = rMedrecords[indexPath.row]
				cell.configureCell(rMedicalRecord: rMedRec)
			}
	
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if inSearchMode {
			
			return rFilteredRecords.count
		}
		else {
			
			return rMedrecords.count
		}
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		var rMedrec: RMedicalRecord
		
		if inSearchMode {
			
			rMedrec = rFilteredRecords[indexPath.row]
			
			checkNetwork()
			
			let isInRLM = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: rMedrec.id)
			
			if isInRLM == nil {
				
				if NetworkConnection.sharedInstance.haveConnection {
					
					self.dataHelper.downloadRecord(recordId: rMedrec.id, completed: {
						
						self.dataHelper.downloadConsultations(recordId: rMedrec.id, completed: {
							
							print("Nueva Historia guardada")
							
							rMedrec = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: rMedrec.id)!
							
							self.performSegue(withIdentifier: "ShowRecordVC", sender: rMedrec)
						})
					})
				}
				else {
					
					// Alerta de que se necesita señal para realizar la busqueda.
				}
			}
			else {
				
				performSegue(withIdentifier: "ShowRecordVC", sender: rMedrec)
			}
		} else {
			
			rMedrec = rMedrecords[indexPath.row]
			
			performSegue(withIdentifier: "ShowRecordVC", sender: rMedrec)
		}
	}

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowRecordVC" {
			
			if let vc = segue.destination as? ShowRecordVC {
				
				if let rMedrec = sender as? RMedicalRecord {
					
					vc.rMedrecord = rMedrec
				}
			}
		}
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		self.view.endEditing(true)
	}
	
	
	@IBAction func segmentedControl(_ sender: UISegmentedControl) {
		
		//..
	}
	
	
	
}
