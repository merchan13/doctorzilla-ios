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
			self.collection.reloadData()
		}
    }
	
	func parseMedicalRecords(completed: @escaping DownloadComplete) {
		
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
					
					let medrec = MedicalRecord(recordId: recordId, lastName: lastName, document: document)
					
					self.medrecord.append(medrec)
					
				}
				
			}
			
			completed()
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
		/*
		var medrec: MedicalRecord
		
		if inSearchMode {
			
			medrec = filteredRecord[indexPath.row]
			
		} else {
			
			medrec = medrecord[indexPath.row]
			
		}
		
		performSegue(withIdentifier: "MedicalRecordVC", sender: medrec)
		*/
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if inSearchMode {
			return filteredRecord.count
		} else {
			return medrecord.count
		}
		//return 30
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
		dismiss(animated: true, completion: nil)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// ...
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
}
