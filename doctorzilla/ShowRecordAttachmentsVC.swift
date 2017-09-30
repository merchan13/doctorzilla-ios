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
	var sortedAttachments: Results<RAttachment>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.sortedAttachments = self.rAttachments.sorted(byKeyPath: "date", ascending: false)
		
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
			
			let rAttachment = self.sortedAttachments[indexPath.row]
			
			cell.configureCell(rAttachment: rAttachment)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.sortedAttachments.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		checkNetwork()
		
		if NetworkConnection.sharedInstance.haveConnection {
			
			let rAttachment = self.sortedAttachments[indexPath.row]
			
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
}
