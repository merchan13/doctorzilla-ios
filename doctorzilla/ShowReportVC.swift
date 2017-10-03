//
//  ShowReportVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/28/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift


class ShowReportVC: UIViewController {

	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var reportContent: UITextView!
	
	var rReport: RReport!
	let realm = try! Realm()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.updateUI()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		self.updateUI()
	}
	
	func updateUI() {
	
		self.date.text = "Informe [\(self.rReport.parsedCreationDate())]"
		
		self.reportContent.text = self.rReport.reportDescription
	}

}
