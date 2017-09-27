//
//  ShowConsultationDiagnosticsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/27/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ShowConsultationDiagnosticsVC: UITableViewController {

	@IBOutlet var diagnosticsTable: UITableView!
	
	var rDiagnostics: List<RDiagnostic>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem?.title = "Consulta"
		
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
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "DiagnosticCell", for: indexPath) as? DiagnosticCell {
			
			let rDiagnostic = self.rDiagnostics[indexPath.row]
			
			cell.configureCell(rDiagnostic: rDiagnostic)
			
			return cell
		}
		else {
			
			return UITableViewCell()
		}
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rDiagnostics.count
	}

}
