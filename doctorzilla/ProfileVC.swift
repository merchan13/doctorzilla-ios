//
//  ProfileVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift
import ReachabilitySwift

class ProfileVC: UITableViewController {

	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	var user = User()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ProfileVC")
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 1 {
			
			if indexPath.row == 0 {
				
				self.user.signOut {
					
					AuthToken.sharedInstance.token = ""
					
					self.performSegue(withIdentifier: "unwindSegueToLoginVC", sender: self)
				}
			}
		}
	}
}
