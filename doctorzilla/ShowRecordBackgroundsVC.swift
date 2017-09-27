//
//  ShowRecordBackgroundsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/15/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class ShowRecordBackgroundsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var backgroundsTable: UITableView!
	
	var rBackgrounds: List<RBackground>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.backgroundsTable.delegate = self
		self.backgroundsTable.dataSource = self
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
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundCell", for: indexPath) as? BackgroundCell {
			
			let rBackground = self.rBackgrounds[indexPath.row]
			
			cell.configureCell(rBackground: rBackground)
			
			return cell
		} else {
			
			return UITableViewCell()
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rBackgrounds.count
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		
		dismiss(animated: true, completion: nil)
	}
}
