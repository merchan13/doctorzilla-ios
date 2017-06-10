//
//  DashboardVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import ReachabilitySwift

class DashboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var collection: UICollectionView!
	
	var user: User!
	var rUser: RUser!
	var medrecord = [MedicalRecord]()
	var filteredRecord = [MedicalRecord]()
	var inSearchMode = false
	let realm = try! Realm()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if AuthToken.sharedInstance.token != "" {
			print(AuthToken.sharedInstance.token)
		}
		
		self.rUser = realm.object(ofType: RUser.self, forPrimaryKey: 1)
		
		collection.dataSource = self
		collection.delegate = self
		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.done
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		checkNetwork()
		
		if networkConnection {
			parseMedicalRecords {
				self.parseRecordsCSV()
				self.collection.reloadData()
			}
		} else {
			parseMedicalRecordsRLM {
				self.parseRecordsCSV()
				self.collection.reloadData()
			}
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	// 1. Get MedicalRecords data from server
	func parseMedicalRecords(completed: @escaping DownloadComplete) {
		let medicalRecordCSV = MedicalRecordCSV()
		var csvText = "id,document,lastName\n"
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let recordDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				try! self.realm.write {
					for rec in recordDictionary {
						let recordId = rec["id"] as! Int
						let document = "\(rec["document_type"]!)-\(rec["document"]!)"
						let lastName = rec["last_name"] as! String
					
						let newLine = "\(recordId),\(document),\(lastName)\n"
						csvText.append(newLine)
					
						//Save to Realm
						if self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: recordId) == nil {
							let rMedRecord = RMedicalRecord()
							rMedRecord.id = recordId
							rMedRecord.document = document
							rMedRecord.lastName = lastName
							self.realm.add(rMedRecord, update: true)
							self.rUser.medrecords.append(rMedRecord)
						}
					}
				}
				medicalRecordCSV.create(csvText: csvText)
			}
			completed()
		}
	}
	
	// 1.1. Get MedicalRecords data from Realm DB
	func parseMedicalRecordsRLM(completed: @escaping DownloadComplete) {
		let medicalRecordCSV = MedicalRecordCSV()
		var csvText = "id,document,lastName\n"
		
		let recordsRealm = realm.objects(RMedicalRecord.self)
		
		for rec in recordsRealm {
			let recordId = rec.id
			let document = rec.document
			let lastName = rec.lastName
			
			let newLine = "\(recordId),\(document),\(lastName)\n"
			csvText.append(newLine)
		}
		
		medicalRecordCSV.create(csvText: csvText)
		completed()
	}
	
	// 2. Load MedicalRecords data from CSV file.
	func parseRecordsCSV() {
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent(RECORDS_CSV)
			
			self.medrecord.removeAll()
			
			do {
				let csv = try CSV(contentsOfURL: path)
				let rows = csv.rows
				
				for row in rows {
					let recordId = Int(row["id"]!)!
					let document = row["document"]!
					let lastName = row["lastName"]!
					let medrec = MedicalRecord(recordId: recordId, document: document, lastName: lastName)
					self.medrecord.append(medrec)
				}
				
			} catch let err as NSError {
				print(err.debugDescription)
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedRecordCell", for: indexPath) as? MedRecordCell {
			
			let medrec: MedicalRecord!
			
			if inSearchMode {
				medrec = filteredRecord[indexPath.row]
				cell.configureCell(medrec)
			} else {
				medrec = medrecord[indexPath.row]
				cell.configureCell(medrec)
			}

			return cell
		} else {
			return UICollectionViewCell()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		var medrec: MedicalRecord
		if inSearchMode {
			medrec = filteredRecord[indexPath.row]
		} else {
			medrec = medrecord[indexPath.row]
		}
		performSegue(withIdentifier: "MedicalRecordVC", sender: medrec)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if inSearchMode {
			return filteredRecord.count
		} else {
			return medrecord.count
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 138, height: 120)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		view.endEditing(true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text == nil || searchBar.text == "" {
			inSearchMode = false
			collection.reloadData()
			view.endEditing(true)
		} else {
			inSearchMode = true
			let criteria = searchBar.text!
			filteredRecord = medrecord.filter({$0.lastName.range(of: criteria) != nil || $0.document.range(of: criteria) != nil})
			collection.reloadData()
		}
	}
	
	@IBAction func logoutButtonTapped(_ sender: Any) {
		AuthToken.sharedInstance.token = ""
		//user = User()
		//user.signOut()
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "MedicalRecordVC" {
			if let recordVC = segue.destination as? MedicalRecordVC {
				if let medrec = sender as? MedicalRecord {
					recordVC.medrecord = medrec
				}
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
}

extension DashboardVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		switch status {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
	
	func checkNetwork() {
		switch ReachabilityManager.shared.reachability.currentReachabilityStatus {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
	
}
