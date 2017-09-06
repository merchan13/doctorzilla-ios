//
//  SettingsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/23/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class SettingsVC: UITableViewController {

	@IBOutlet weak var profilePictureImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var syncActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var resetActivityIndicator: UIActivityIndicatorView!
	
	var rUser: RUser!
	let realm = try! Realm()
	let sync = Synchronize()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.rUser = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)
		
		self.updateUI()
    }
	
	func updateUI() {
		//self.nameLabel.text = "Dr. \(self.rUser.name) \(self.rUser.lastName)."
		self.emailLabel.text = self.rUser.email
		//self.profilePictureImageView.image = self.rUser.profilePicture
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		self.deselectRow()
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			
			if indexPath.row == 0 {
				// Ver perfil
			}
			
		} else if indexPath.section == 1 {
			checkNetwork()
			
			if networkConnection {
				
				// [Sincronizacion]
				if indexPath.row == 0 {
					
					self.synchronizeDrZilla()
					
				} else if indexPath.row == 1 { // [Restauracion]
					
					self.resetDrZilla()
					
				}
			} else {
				
				self.offlineAlert()
				
			}
		}
	}
	
	
	/// Sincronizar bases de datos.
	//
	func synchronizeDrZilla() {
		let syncAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere sincronizar los datos?", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				self.syncActivityIndicator.startAnimating()
			}
			
			self.sync.synchronizeDatabases(user: self.rUser, completed: {
				
				DispatchQueue.main.async {
					self.syncActivityIndicator.stopAnimating()
				}
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido sincronizados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
					self.dismiss(animated: true, completion: nil)
				}))
				
				self.present(successAlert, animated: true, completion: nil)
			})
		}))
		
		syncAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			self.deselectRow()
			print("Sync Canceled")
		}))
		
		self.present(syncAlert, animated: true, completion: nil)
	}
	
	
	/// Borrar base de datos del teléfono y descarga toda la información del servidor.
	//
	func resetDrZilla() {
		let syncAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere eliminar y restaurar los datos?\n\nLuego de realizar esta acción, deberá iniciar sesión nuevamente.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			DispatchQueue.main.async {
				self.resetActivityIndicator.startAnimating()
			}
			
			self.sync.resetDatabase(user: self.rUser, completed: {
				
				DispatchQueue.main.async {
					self.resetActivityIndicator.stopAnimating()
				}
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido restaurados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
					self.performSegue(withIdentifier: "LoginVC", sender: nil)
				}))
				
				self.present(successAlert, animated: true, completion: nil)
			})
		}))
		
		syncAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			self.deselectRow()
			print("Sync Canceled")
		}))
		
		self.present(syncAlert, animated: true, completion: nil)
	}
	
	
	/// Alerta al no poseer conexión a internet.
	//
	func offlineAlert() {
		let offlineAlert = UIAlertController(title: "Sin conexión a Internet", message: "Esta acción no puede realizarse sin conexión a Internet", preferredStyle: UIAlertControllerStyle.alert)
		
		offlineAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
			self.deselectRow()
		}))
		
		self.present(offlineAlert, animated: true, completion: nil)
	}
	
	
	func deselectRow() {
		if let index = self.tableView.indexPathForSelectedRow{
			self.tableView.deselectRow(at: index, animated: true)
		}
	}
	
}

extension SettingsVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		if status == .notReachable {
			networkConnection = false
		} else {
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





