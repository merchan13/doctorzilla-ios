//
//  LoginVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import ReachabilitySwift

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	let user = User()
	var rUser = RUser()
	let realm = try! Realm()
	let sync = Synchronize()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("\nPath to Realm file: \(realm.configuration.fileURL!.absoluteString)\n")
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	@IBAction func loginButtonTapped(_ sender: Any) {
		let userEmail = emailTextField.text!
		let userPassword = passwordTextField.text!
		
		DispatchQueue.main.async {
			self.activityIndicatorView.startAnimating()
		}
		
		checkNetwork()
		
		if networkConnection {
			user.signIn(email: userEmail, password: userPassword) {
				if AuthToken.sharedInstance.token != "" && AuthToken.sharedInstance.token != nil {
					try! self.realm.write {
						if self.realm.object(ofType: RUser.self, forPrimaryKey: 1) == nil {
							let rUser = RUser()
							rUser.id = 1
							rUser.email = self.user.email
							rUser.password = self.user.password
							self.realm.add(rUser, update: true)
							self.rUser = rUser
						} else {
							self.rUser = self.realm.object(ofType: RUser.self, forPrimaryKey: 1)!
						}
					}
					
					self.sync.synchronizeDatabases(user: self.rUser) {
						DispatchQueue.main.async {
							self.activityIndicatorView.stopAnimating()
						}
						self.performSegue(withIdentifier: "DashboardVC", sender: self.rUser)
					}
					
				} else {
					DispatchQueue.main.async {
						self.activityIndicatorView.stopAnimating()
						self.loginAlert()
					}
				}
			}
		} else {
			if let userInRealm = self.realm.object(ofType: RUser.self, forPrimaryKey: 1) {
				self.rUser = userInRealm
			}
			if self.rUser.signIn(email: userEmail, password: userPassword) {
				DispatchQueue.main.async {
					self.activityIndicatorView.stopAnimating()
		
					self.performSegue(withIdentifier: "DashboardVC", sender: self.rUser)
				}
			} else {
				DispatchQueue.main.async {
					self.activityIndicatorView.stopAnimating()
					self.loginAlert()
				}
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DashboardVC" {
			if let tabBarVC = segue.destination as? UITabBarController {
				if let dashboardVC = tabBarVC.viewControllers!.first as? DashboardVC {
					if let rUser = sender as? RUser {
						dashboardVC.rUser = rUser
					}
				}
			}
		}
	}
	
	func loginAlert() {
		let alertController = UIAlertController(title: "Error", message: "La contraseña o correo que introdujo son inválidos", preferredStyle: .alert)
		
		let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alertController.addAction(defaultAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
    //Cerrar teclado cuando se toca cualquier espacio de la pantalla.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Cerrar teclado cuando se presiona "return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		switch status {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
	
	func checkNetwork() {
		switch ReachabilityManager.shared.reachability.currentReachabilityStatus {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
}

