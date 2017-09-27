//
//  ShowConsultationExamsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/27/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ShowConsultationExamsVC: UITableViewController {

	@IBOutlet var examsTable: UITableView!
	
	var rExams: List<RPhysicalExam>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.examsTable.delegate = self
		self.examsTable.dataSource = self
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
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ExamCell", for: indexPath) as? ExamCell {
			
			let rExam = self.rExams[indexPath.row]
			
			cell.configureCell(rExam: rExam)
			
			return cell
		}
		else {
			
			return UITableViewCell()
		}
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rExams.count
	}
	
}
