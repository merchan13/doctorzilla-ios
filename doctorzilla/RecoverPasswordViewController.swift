//
//  RecoverPasswordViewController.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class RecoverPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: UITextField!
    
    @IBAction func recoverButtonTapped(_ sender: Any) {
        
        let userEmail = emailTextField.text!
        
        // Check for empty fields
        if (userEmail.isEmpty) {
        
            // Display alert message
            displayAlertMessage(userMessage: "Introduzca su correo por favor.", userTitle: "Importante!")
 
            return
        
        }
        
        
        // Send mail
        print("Enviando correo con contraseña...")
        
        // Display alert message with confirmation
        displaySuccessMessage(userMessage: "Su contraseña fue enviada a su correo.", userTitle: "Éxito")
    
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func displayAlertMessage (userMessage: String, userTitle: String) {
        
        let alertController = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func displaySuccessMessage (userMessage: String, userTitle: String) {
        print("entro en success")
        let alertController = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ action in
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    /* 
     
     BASIC FUNCS
     
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
