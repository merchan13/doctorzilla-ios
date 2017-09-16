//
//  ShowRecordAttachmentsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/15/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift
import SafariServices

class ShowRecordAttachmentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var attachmentsTable: UITableView!
	
	var rAttachments: List<RAttachment>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	var networkConnection = false
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.attachmentsTable.delegate = self
		self.attachmentsTable.dataSource = self
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath) as? AttachmentCell {
			
			let rAttachment = self.rAttachments[indexPath.row]
			
			cell.configureCell(rAttachment: rAttachment)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rAttachments.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		checkNetwork()
		
		if self.networkConnection {
			
			let rAttachment = self.rAttachments[indexPath.row]
			
			self.dataHelper.downloadAttachmentURL(id: rAttachment.id) { (result: String) in
				
				let svc = SFSafariViewController(url: URL(string: result)!)
				
				self.present(svc, animated: true, completion: nil)
			}
		}
		else {
			
			let cantShowAttachmentAlert = UIAlertController(title: "SIN CONEXIÓN", message: "Los anexos sólo pueden ser vistos con conexión a internet.", preferredStyle: UIAlertControllerStyle.alert)
			
			cantShowAttachmentAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
				
			}))
			
			self.present(cantShowAttachmentAlert, animated: true, completion: nil)
		}
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		
		dismiss(animated: true, completion: nil)
	}
	
	
	func recoveredNetworkData() {
		let syncAlert = UIAlertController(title: "ALERTA", message: "Se ha recupero la conexión a internet, se recomienda que sincronice los datos antes de seguir.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Sincronizar", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				//self.activityIndicator.startAnimating()
			}
			
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			
			self.sync.synchronizeDatabases(user: user, completed: {
				
				self.attachmentsTable.reloadData()
				
				DispatchQueue.main.async {
					//self.activityIndicator.stopAnimating()
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

extension ShowRecordAttachmentsVC: NetworkStatusListener {
	
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
