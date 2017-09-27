//
//  ShowRecordDiagnosticsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/15/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ShowRecordDiagnosticsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var diagnosticsTable: UITableView!
	
	var rDiagnostics: [RDiagnostic]!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.diagnosticsTable.delegate = self
		self.diagnosticsTable.dataSource = self
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
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "DiagnosticCell", for: indexPath) as? DiagnosticCell {
			
			let rDiagnostic = self.rDiagnostics[indexPath.row]
			
			cell.configureCell(rDiagnostic: rDiagnostic)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rDiagnostics.count
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		
		dismiss(animated: true, completion: nil)
	}
	
	/*
	func recoveredNetworkData() {
		let syncAlert = UIAlertController(title: "ALERTA", message: "Se ha recupero la conexión a internet, se recomienda que sincronice los datos antes de seguir.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Sincronizar", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				//self.activityIndicator.startAnimating()
			}
			
			let user = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
			
			self.sync.synchronizeDatabases(user: user, completed: {
				
				self.diagnosticsTable.reloadData()
				
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
	*/
}
