//
//  DashboardVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
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
				self.collection.reloadData()
				self.dowloadProfilePictures {
					self.collection.reloadData()
				}
			}
		} else {
			parseMedicalRecordsRLM {
				self.collection.reloadData()
			}
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	// Get MedicalRecords data from server
	func parseMedicalRecords(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let recordDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				self.medrecord.removeAll()
				
				for rec in recordDictionary {
					let recordId = rec["id"] as! Int
					let document = "\(rec["document_type"]!)-\(rec["document"]!)"
					let lastName = rec["last_name"] as! String
					let profilePicURL = rec["profile_picture"] as! String
					
					let medrec = MedicalRecord(recordId: recordId, document: document, lastName: lastName, profilePicURL: profilePicURL)
					self.medrecord.append(medrec)
				}
			}
			completed()
		}
	}
	
	// Get MedicalRecords data from Realm DB
	func parseMedicalRecordsRLM(completed: @escaping DownloadComplete) {
		
		let recordsRealm = realm.objects(RMedicalRecord.self)
		
		for rec in recordsRealm {
			let recordId = rec.id
			let document = rec.document
			let lastName = rec.lastName
			let profilePic = rec.profilePic
			
			let medrec = MedicalRecord(recordId: recordId, document: document, lastName: lastName, profilePic: profilePic)
			self.medrecord.append(medrec)
		}
		completed()
	}
	
	// Download MedicalRecord profile pictures
	func dowloadProfilePictures(completed: @escaping DownloadComplete) {
		for rec in self.medrecord {
			Alamofire.request(rec.profilePicURL).responseImage { response in
				if let image = response.result.value {
					let size = CGSize(width: 100.0, height: 100.0)
					let resizedImage = image.af_imageAspectScaled(toFit: size)
					let circularImage = resizedImage.af_imageRoundedIntoCircle()
					let imageData:NSData = UIImagePNGRepresentation(circularImage)! as NSData
					rec.profilePic = imageData
					
					//Save to Realm
					try! self.realm.write {
						if self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: rec.recordId) == nil {
							let rMedRecord = RMedicalRecord()
							rMedRecord.id = rec.recordId
							rMedRecord.document = rec.document
							rMedRecord.lastName = rec.lastName
							self.realm.add(rMedRecord, update: true)
							self.rUser.medrecords.append(rMedRecord)
						}
						self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: rec.recordId)?.profilePic = rec.profilePic
					}
				}
				completed()
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
