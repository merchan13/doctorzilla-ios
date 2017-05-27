//
//  DashboardVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire

class DashboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var collection: UICollectionView!
	
	var user: User!
	
	var medrecord = [MedicalRecord]()
	var filteredRecord = [MedicalRecord]()
	var inSearchMode = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collection.dataSource = self
		collection.delegate = self
		searchBar.delegate = self
		
		searchBar.returnKeyType = UIReturnKeyType.done
		
		parseMedicalRecords {
			self.parseRecordsCSV()
			self.collection.reloadData()
		}
		
    }
	
	func parseMedicalRecords(completed: @escaping DownloadComplete) {
		
		let medicalRecordCSV = MedicalRecordCSV()
		var csvText = "id,document,lastName\n"
		
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			
			if let recordDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
		
				for rec in recordDictionary {
					let recordId = rec["id"] as! Int
					let document = "\(rec["document_type"]!)-\(rec["document"]!)"
					let lastName = rec["last_name"] as! String
					
					let newLine = "\(recordId),\(document),\(lastName)\n"
					csvText.append(newLine)
				}
				
				medicalRecordCSV.create(csvText: csvText)
		
			}
			completed()
		}
		
	}
	
	func parseRecordsCSV() {
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			
			let path = dir.appendingPathComponent(RECORDS_CSV)
			
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
