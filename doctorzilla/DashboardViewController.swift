//
//  DashboardViewController.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

	@IBOutlet weak var tokenLabel: UILabel!
	@IBOutlet weak var doctorLabel: UILabel!
	
	@IBAction func logoutButtonTapped(_ sender: Any) {
		
		AuthToken.sharedInstance.token = ""
		
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
		self.present(vc!, animated: true, completion: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		tokenLabel.text = "Token: \(AuthToken.sharedInstance.token!)"
		
    }
	
}
