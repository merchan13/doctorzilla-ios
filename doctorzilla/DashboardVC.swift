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
	var medrecords = [MedicalRecord]()
	var rMedrecords = [RMedicalRecord]()
	var filteredRecords = [MedicalRecord]()
	var rFilteredRecords = [RMedicalRecord]()
	var inSearchMode = false
	let realm = try! Realm()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if AuthToken.sharedInstance.token != nil {
			print("[ \(AuthToken.sharedInstance.token!) ]\n")
		}
		
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
				///*
				self.dowloadProfilePictures {
					self.collection.reloadData()
				}
				//*/
				//self.collection.reloadData()
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
				self.medrecords.removeAll()
				
				for rec in recordDictionary {
					let recordId = rec["id"] as! Int
					let document = "\(rec["document_type"]!)-\(rec["document"]!)"
					let lastName = rec["last_name"] as! String
					let profilePicURL = rec["profile_picture"] as! String
					
					let medrec = MedicalRecord(recordId: recordId, document: document, lastName: lastName, profilePicURL: profilePicURL)
					self.medrecords.append(medrec)
				}
			}
			completed()
		}
	}
	
	// Get MedicalRecords data from Realm DB
	func parseMedicalRecordsRLM(completed: @escaping DownloadComplete) {
		
		let recordsRealm = realm.objects(RMedicalRecord.self)
		self.rMedrecords.removeAll()
		for rec in recordsRealm {
			self.rMedrecords.append(rec)
		}
		completed()
	}
	
	// Download MedicalRecord profile pictures
	func dowloadProfilePictures(completed: @escaping DownloadComplete) {
		for rec in self.medrecords {
			Alamofire.request(rec.profilePicURL).responseImage { response in
				if let image = response.result.value {
					let size = CGSize(width: 100.0, height: 100.0)
					let resizedImage = image.af_imageAspectScaled(toFit: size)
					let circularImage = resizedImage.af_imageRoundedIntoCircle()
					let imageData:NSData = UIImagePNGRepresentation(circularImage)! as NSData
					rec.profilePic = imageData
					
					//Save to Realm profile pictures.
					try! self.realm.write {
						self.realm.create(RMedicalRecord.self, value: ["id": rec.recordId, "profilePic": rec.profilePic], update: true)
					}
				}
				completed()
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedRecordCell", for: indexPath) as? MedRecordCell {
			if networkConnection {
				let medrec: MedicalRecord!
				if inSearchMode {
					medrec = filteredRecords[indexPath.row]
					cell.configureCell(medrec)
				} else {
					medrec = medrecords[indexPath.row]
					cell.configureCell(medrec)
				}
				return cell
			} else {
				let medrec: RMedicalRecord!
				if inSearchMode {
					medrec = rFilteredRecords[indexPath.row]
					cell.configureCell(medrec)
				} else {
					medrec = rMedrecords[indexPath.row]
					cell.configureCell(medrec)
				}
				return cell
			}
		} else {
			return UICollectionViewCell()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if networkConnection {
			var medrec: MedicalRecord
			if inSearchMode {
				medrec = filteredRecords[indexPath.row]
			} else {
				medrec = medrecords[indexPath.row]
			}
			performSegue(withIdentifier: "MedicalRecordVC", sender: medrec)
		} else {
			var rMedrec: RMedicalRecord
			if inSearchMode {
				rMedrec = rFilteredRecords[indexPath.row]
			} else {
				rMedrec = rMedrecords[indexPath.row]
			}
			performSegue(withIdentifier: "MedicalRecordVC", sender: rMedrec)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if networkConnection {
			if inSearchMode {
				return filteredRecords.count
			} else {
				return medrecords.count
			}
		} else {
			if inSearchMode {
				return rFilteredRecords.count
			} else {
				return rMedrecords.count
			}
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
			if networkConnection {
				filteredRecords = medrecords.filter({$0.lastName.range(of: criteria) != nil || $0.document.range(of: criteria) != nil})
			} else {
				rFilteredRecords = rMedrecords.filter({$0.lastName.range(of: criteria) != nil || $0.document.range(of: criteria) != nil})
			}
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
				if networkConnection {
					if let medrec = sender as? MedicalRecord {
						recordVC.medrecord = medrec
					}
				} else {
					if let rMedrec = sender as? RMedicalRecord {
						recordVC.rMedrecord = rMedrec
					}
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
