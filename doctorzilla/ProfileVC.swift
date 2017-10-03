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

	@IBOutlet weak var photo: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var document: UILabel!
	@IBOutlet weak var email: UILabel!
	@IBOutlet weak var phone: UILabel!
	
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	var user = User()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ProfileVC")
		
		if let loggedUser = self.realm.objects(RUser.self).first {
			
			self.name.text = "Dr. \(loggedUser.name) \(loggedUser.lastName)"
			
			self.document.text = loggedUser.document
			
			self.email.text = loggedUser.email
			
			self.phone.text = loggedUser.phone
		}
		else {
			
			self.name.text = "No disponible"
			
			self.document.text = "No disponible"
			
			self.email.text = "No disponible"
			
			self.phone.text = "No disponible"
		}
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 1 {
			
			if indexPath.row == 0 {
				
				checkNetwork()
				
				if NetworkConnection.sharedInstance.haveConnection {
					
					self.user.signOut {
						
						AuthToken.sharedInstance.token = ""
						
						self.performSegue(withIdentifier: "unwindSegueToLoginVC", sender: self)
					}
				}
				else {
					
					AuthToken.sharedInstance.token = ""
					
					self.performSegue(withIdentifier: "unwindSegueToLoginVC", sender: self)
				}
			}
		}
	}
}
