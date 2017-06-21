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
	var rMedrecords = [RMedicalRecord]()
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
	
	override func viewDidAppear(_ animated: Bool) {
		checkNetwork()
		
		parseMedicalRecordsRLM {
			self.collection.reloadData()
			
			if self.networkConnection {
				self.dowloadProfilePictures {
					self.collection.reloadData()
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
		
		completed()
	}
	
	/// Download MedicalRecord profile pictures
	//
	func dowloadProfilePictures(completed: @escaping DownloadComplete) {
		for rec in self.rMedrecords {
			Alamofire.request(rec.profilePicURL).responseImage { response in
				if let image = response.result.value {
					let size = CGSize(width: 100.0, height: 100.0)
					let resizedImage = image.af_imageAspectScaled(toFit: size)
					let circularImage = resizedImage.af_imageRoundedIntoCircle()
					let imageData:NSData = UIImagePNGRepresentation(circularImage)! as NSData
					
					try! self.realm.write {
						rec.profilePic = imageData
					}
				}
				completed()
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedRecordCell", for: indexPath) as? MedRecordCell {
			let medrec: RMedicalRecord!
			if inSearchMode {
				medrec = rFilteredRecords[indexPath.row]
				cell.configureCell(medrec)
			} else {
				medrec = rMedrecords[indexPath.row]
				cell.configureCell(medrec)
			}
			
			return cell
			
		} else {
			return UICollectionViewCell()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		var rMedrec: RMedicalRecord
		
		if inSearchMode {
			rMedrec = rFilteredRecords[indexPath.row]
		} else {
			rMedrec = rMedrecords[indexPath.row]
		}
		
		performSegue(withIdentifier: "MedicalRecordVC", sender: rMedrec)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if inSearchMode {
			return rFilteredRecords.count
		} else {
			return rMedrecords.count
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
			rFilteredRecords = rMedrecords.filter({$0.lastName.range(of: criteria) != nil || $0.document.range(of: criteria) != nil})
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
				if let rMedrec = sender as? RMedicalRecord {
					recordVC.rMedrecord = rMedrec
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
