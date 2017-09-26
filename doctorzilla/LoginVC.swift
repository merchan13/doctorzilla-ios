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
	
	@IBAction func unwindToLoginVC(segue:UIStoryboardSegue) { }
	
	
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
		
		if let userInRealm = self.realm.objects(RUser.self).first {
			
			self.rUser = userInRealm
			
			if self.rUser.signIn(email: userEmail, password: userPassword) {
				
				DispatchQueue.main.async {
					
					self.activityIndicatorView.stopAnimating()
					
					self.performSegue(withIdentifier: "LoginSuccessful", sender: self.rUser)
				}
			}
			else {
				
				DispatchQueue.main.async {
					
					self.activityIndicatorView.stopAnimating()
					
					self.loginFailAlert(error: "La contraseña o correo que introdujo son inválidos")
				}
			}
		}
		else {
			
			checkNetwork()
			
			if networkConnection {
				
				self.firstTimeLogin(userEmail: userEmail, userPassword: userPassword)
			}
			else {
				
				DispatchQueue.main.async {
					
					self.activityIndicatorView.stopAnimating()
					
					self.loginFailAlert(error: "Para iniciar por primera vez en la aplicación debe iniciar sesión a través de una conexión a internet")
				}
			}
		}
	}
	
	
	func loginFailAlert(error: String) {
		
		let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
		
		let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		
		alertController.addAction(defaultAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	
	// Log in for the first time: save the user info & download the latest data
	func firstTimeLogin(userEmail: String, userPassword: String){
		
		self.user.signIn(email: userEmail, password: userPassword) {
			
			if AuthToken.sharedInstance.token != "" && AuthToken.sharedInstance.token != nil {
				
				try! self.realm.write {
					
					if self.realm.object(ofType: RUser.self, forPrimaryKey: self.user.id) == nil {
						
						self.realm.deleteAll()
						
						let rUser = RUser()
						rUser.id = self.user.id
						rUser.email = self.user.email
						rUser.password = self.user.password
						//rUser.name = self.user.name
						//rUser.lastName = self.user.lastName
						//rUser.document = self.user.document
						
						self.realm.add(rUser, update: true)
						
						self.rUser = rUser
					}
					else {
						
						self.rUser = self.realm.object(ofType: RUser.self, forPrimaryKey: self.user.id)!
					}
				}
				
				self.sync.downloadRecords {
					
					DispatchQueue.main.async {
						
						self.activityIndicatorView.stopAnimating()
					}
					
					self.performSegue(withIdentifier: "LoginSuccessful", sender: self.rUser)
				}
				
			}
			else {
				
				DispatchQueue.main.async {
					
					self.activityIndicatorView.stopAnimating()
					
					self.loginFailAlert(error: self.user.error)
				}
			}
		}
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
		if status == .notReachable {
			networkConnection = false
		} else {
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

