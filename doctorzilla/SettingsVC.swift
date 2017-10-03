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
	
	var rUser: RUser!
	let realm = try! Realm()
	let sync = Synchronize()
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		if let user = self.realm.objects(RUser.self).first {
			
			self.rUser = user
		}
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.deselectRow()
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 0 {
			
			checkNetwork()
			
			if NetworkConnection.sharedInstance.haveConnection {
				
				if indexPath.row == 0 {
					
					self.synchronizeDrZilla()
				}
				else if indexPath.row == 1 {
					
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
			
			self.sync.downloadRecords {
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido sincronizados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
					
					self.navigationController?.popViewController(animated: true)
				}))
				
				self.present(successAlert, animated: true, completion: nil)
			}
		}))
		
		syncAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			
			self.deselectRow()
			
			print("Sync Canceled")
		}))
		
		self.present(syncAlert, animated: true, completion: nil)
	}
	
	
	/// Borrar base de datos del teléfono.
	//
	func resetDrZilla() {
		
		let syncAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere restaurar la aplicación a su estado inicial?\n\nLuego de realizar esta acción, deberá iniciar sesión nuevamente.", preferredStyle: UIAlertControllerStyle.alert)
		
		syncAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			self.sync.resetDatabase{
				
				let successAlert = UIAlertController(title: "Sincronización", message: "Los datos han sido restaurados con éxito", preferredStyle: UIAlertControllerStyle.alert)
				
				successAlert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (action: UIAlertAction!) in
					
					self.performSegue(withIdentifier: "unwindSegueToLoginVC", sender: self)
				}))
				
				self.present(successAlert, animated: true, completion: nil)
			}
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




