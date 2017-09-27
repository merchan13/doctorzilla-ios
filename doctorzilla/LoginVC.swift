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
			
			self.login(email: userEmail, password: userPassword)
		}
		else {
			
			self.firstTimeLogin(userEmail: userEmail, userPassword: userPassword)
		}
	}
	
	
	/// Login
	//
	func login(email: String, password: String) {
		
		checkNetwork()
		
		if NetworkConnection.sharedInstance.haveConnection {
		
			self.user.signIn(email: email, password: password, completed: {
				
				if AuthToken.sharedInstance.token != "" && AuthToken.sharedInstance.token != nil {
				
					self.checkNewUser(email: email, password: password, completed: {
					
						DispatchQueue.main.async {
							
							self.activityIndicatorView.stopAnimating()
							
							self.performSegue(withIdentifier: "LoginSuccessful", sender: self.rUser)
						}
					})
				}
				else {
					
					DispatchQueue.main.async {
						
						self.activityIndicatorView.stopAnimating()
						
						self.loginFailAlert(error: "La contraseña o correo que introdujo son inválidos")
					}
				}
			})
		}
		else {
			
			self.offlineLogin(user: self.rUser)
		}
	}
	
	
	///
	//
	func checkNewUser(email: String, password: String, completed: @escaping DownloadComplete) {
	
		if self.user.id == self.rUser.id {
			
			try! self.realm.write {
				
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
			
			completed()
		}
		else { // Is a new user, delete all and 'reset' and reset all data
			
			try! self.realm.write {
				
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
			
			self.sync.downloadRecords {
				
				completed()
			}
		}
	}
	
	
	/// Offline login
	//
	func offlineLogin(user: RUser){
		
		if self.rUser.signIn(email: user.email, password: user.password) {
			
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
	
	
	/// Log in for the first time: save the user info & download the latest data
	//
	func firstTimeLogin(userEmail: String, userPassword: String){
		
		checkNetwork()
		
		if NetworkConnection.sharedInstance.haveConnection {
			
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
		else {
			
			DispatchQueue.main.async {
				
				self.activityIndicatorView.stopAnimating()
				
				self.loginFailAlert(error: "Para iniciar por primera vez en la aplicación debe iniciar sesión a través de una conexión a internet")
			}
		}
	}
	
	
	/// Mensaje de error en login
	//
	func loginFailAlert(error: String) {
		
		let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
		
		let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		
		alertController.addAction(defaultAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	
    /// Cerrar teclado cuando se toca cualquier espacio de la pantalla.
	//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
        self.view.endEditing(true)
    }
	
	
    ///Cerrar teclado cuando se presiona "return"
	//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
        textField.resignFirstResponder()
		
        return true
    }
    
}
