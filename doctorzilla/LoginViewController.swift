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
            if AuthToken.sharedInstance.token != nil {
                DispatchQueue.main.async {
                    print("valido")
                    self.activityIndicatorView.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    print("no valido")
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

