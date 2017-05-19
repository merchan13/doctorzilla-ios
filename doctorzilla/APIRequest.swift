//
//  Request.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/11/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class APIRequest {

    // POST
    func postRequest(route: String, params: [String: Dictionary<String,String>], completion: @escaping (AnyObject?) -> ()) {
        
        let parameters = params
        
        guard let url = URL(string: "https://doctorzilla-api.herokuapp.com/" + route) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let htttBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = htttBody
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response {
                
                print(response)
                
            }
            
            if let data = data {
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject

                    completion(json)
                    
                } catch {
                    
                    print(error)
                    
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    // GET
    func getRequest() {
        
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
    

}
