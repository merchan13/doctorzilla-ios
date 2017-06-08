//
//  LoginVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import ReachabilitySwift

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var user: User!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let userEmail = emailTextField.text!
        let userPassword = passwordTextField.text!
        
        user = User()
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
        

        user.signIn(email: userEmail, password: userPassword) {
            if AuthToken.sharedInstance.token != "" && AuthToken.sharedInstance.token != nil {
                DispatchQueue.main.async {
					self.activityIndicatorView.stopAnimating()
					
					self.performSegue(withIdentifier: "DashboardVC", sender: self.user)
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
					
					let alertController = UIAlertController(title: "Error", message: "La contraseña o correo que introdujo son inválidos", preferredStyle: .alert)
					
					let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
					alertController.addAction(defaultAction)
					
					self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
			debugPrint("ViewController: Network became unreachable")
		case .reachableViaWiFi:
			debugPrint("ViewController: Network reachable through WiFi")
		case .reachableViaWWAN:
			debugPrint("ViewController: Network reachable through Cellular Data")
		}
		
	}
}

