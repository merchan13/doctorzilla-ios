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
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var rMedrecords = [RMedicalRecord]()
	var rFilteredRecords = [RMedicalRecord]()
	var inSearchMode = false
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	let user = User()
	
	var firstTime = true
	var reloadImages = false
	
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
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		checkNetwork()
		
		parseMedicalRecordsRLM {
			self.collection.reloadData()
			
			/*
			if self.networkConnection && self.firstTime || self.networkConnection && self.reloadImages {
				for rec in self.rMedrecords {
					self.dataHelper.downloadProfilePicture(rec: rec, completed: {
						self.collection.reloadData()
						self.firstTime = false
						print("Fotos descargadas")
					})
				}
				self.reloadImages = false
			}
			*/
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
			rFilteredRecords = rMedrecords.filter(
				{
					$0.lastName.lowercased().range(of: criteria.lowercased()) != nil ||
					$0.document.lowercased().range(of: criteria.lowercased()) != nil ||
					$0.name.lowercased().range(of: criteria.lowercased()) != nil
				})
			collection.reloadData()
		}
	}
	
	
	@IBAction func settingsButtonTapped(_ sender: Any) {
		self.reloadImages = true
		performSegue(withIdentifier: "SettingsVC", sender: nil)
	}
	
	
	@IBAction func logoutButtonTapped(_ sender: Any) {
		
		self.firstTime = true
		
		self.user.signOut() {
			
			AuthToken.sharedInstance.token = ""
			
			self.dismiss(animated: true, completion: nil)
		}
		
		
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
	
	
	func recoveredNetworkData() {
		let syncAlert = UIAlertController(title: "ALERTA", message: "Se ha recupero la conexión a internet, se recomienda que sincronice los datos antes de seguir.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Sincronizar", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				self.activityIndicator.startAnimating()
			}
			
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			
			self.sync.synchronizeDatabases(user: user, completed: {
				
				self.parseMedicalRecordsRLM {
					self.collection.reloadData()
				}
				
				DispatchQueue.main.async {
					self.activityIndicator.stopAnimating()
				}
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido sincronizados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in

				}))
				
				self.present(successAlert, animated: true, completion: nil)
			})
		}))
		
		syncAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			print("Sync Canceled")
		}))
		
		self.present(syncAlert, animated: true, completion: nil)
	}
	
}

extension DashboardVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		if status == .notReachable {
			let successAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Actualmente no posee conexión a internet.\n\nSe advierte que es posible que trabaje con información desactualizada.", preferredStyle: UIAlertControllerStyle.alert)
			
			successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(successAlert, animated: true, completion: nil)
		} else {
			networkConnection = true
			self.recoveredNetworkData()
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
