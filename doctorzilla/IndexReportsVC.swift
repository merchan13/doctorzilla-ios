//
//  IndexReportsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/28/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class IndexReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var reportsTable: UITableView!
	
	var rReports: List<RReport>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
	override func viewDidLoad() {
		
        super.viewDidLoad()

		self.reportsTable.delegate = self
		self.reportsTable.dataSource = self
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		if let index = self.reportsTable.indexPathForSelectedRow{
			
			self.reportsTable.deselectRow(at: index, animated: true)
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as? ReportCell {
			
			let rReport = self.rReports[indexPath.row]
			
			cell.configureCell(rReport: rReport)
			
			return cell
		}
		else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rReports.count
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let rReport = self.rReports[indexPath.row]
		
		performSegue(withIdentifier: "ShowReportVC", sender: rReport)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let vc = segue.destination as? ShowReportVC, segue.identifier == "ShowReportVC" {
			
			if let rReport = sender as? RReport {
				
				//vc.rReport = rReport
			}
		}
	}

}
