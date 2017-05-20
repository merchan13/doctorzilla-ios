//
//  LoginViewController.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
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
					
					let vc = self.storyboard?.instantiateViewController(withIdentifier: "dashboardView")
					self.present(vc!, animated: true, completion: nil)
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

