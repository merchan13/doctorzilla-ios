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
    
    @IBAction func onGetTapped(_ sender: Any) {
    
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            if let response = response {
            
                print(response)
                
            }
            
            if let data = data {
            
                print(data)
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                
                } catch {
                
                    print(error)
                    
                }
                
            }
        
        }.resume()
    
    }
    
    @IBAction func onPostTapped(_ sender: Any) {
    
        let parameters = ["user_login": ["email": "merchan2000@gmail.com", "password": "qwerty123"]]
        
        guard let url = URL(string: "https://doctorzilla-api.herokuapp.com/sign-in") else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let htttBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = htttBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let response = response {
            
                print(response)
                
            }
            
            
            if let data = data {
            
                do {
                
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    
                    print(json)
                    
                    if let json = json as? NSDictionary {
                    
                        let token = json["auth_token"]!
                    
                    }
                    
                    
                } catch {
                
                    print(error)
                
                }
                
            }
            
        }.resume()
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let userEmail = emailTextField.text!
        
        let userPassword = passwordTextField.text!
        
        print(signIn(email: userEmail, password: userPassword))
        
    }
    
    // GET /user + Authorization: Token token: XXX
    func getUsers() {
        
        // set up the URL request
        let todoEndpoint: String = "https://doctorzilla-api.herokuapp.com/users/1"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /users/")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["email"] as? String else {
                    print("Could not get user email from JSON")
                    return
                }
                print("User email: " + todoTitle)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        
        task.resume()
        
    }
    
    
    // POST /sign-in + params: [user_login][email]&[user_login][password]
    func signIn(email: String, password: String) -> String {
        
        let authenticationToken: String = ""
        
        // set up the URL request
        let todoEndpoint: String = "https://doctorzilla-api.herokuapp.com/sign-in"
        
        guard let url = URL(string: todoEndpoint) else {
        
            print("Error: cannot create URL")
            
            return authenticationToken
        
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        
        var postString: String?
        
        postString = "user_login[email]=" + email + "&user_login[password]=" + password
        
        urlRequest.httpBody = postString!.data(using: .utf8)
        
        // set up the session
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
        
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                
                print("error calling POST on /sign-in")
            
                print(error)
                
                return
                
            }
            // make sure we got data
            guard let responseData = data else {
                
                print("Error: did not receive data")
                
                return
                
            }
            // parse the result as JSON, since that's what the API provides
            do {
                
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                
                print("RESPONSE: " + todo.description)
                
                guard let authenticationToken = todo["auth_token"] as? String else {
                    print("Could not get user token from JSON")
                    return
                }
                
            } catch  {
                
                print("error trying to convert data to JSON")
            
            }
        }
        
        task.resume()
        
        return authenticationToken
    }
    
    /*
     
     BASICS FUNCS
     
     */
    
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

