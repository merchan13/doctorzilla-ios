//
//  UserViewController.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/11/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBAction func logOutButtonTapped(_ sender: Any) {
    
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        
        UserDefaults.standard.synchronize()
        
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = loginViewController
        
        appDelegate.window?.makeKeyAndVisible()
    
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
    
}
