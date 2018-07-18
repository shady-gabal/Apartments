//
//  LoginViewController.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  @IBAction func loginButtonTapped(_ sender: Any) {
    let email = emailField.text ?? ""
    let password = passwordField.text ?? ""
    
    if email.isEmpty {
      return self.showAlert(title: "Missing fields", message: "Please fill in your email address.")
    }
    else if password.isEmpty {
      return self.showAlert(title: "Missing fields", message: "Please fill in your password")
    }
    
    NetworkManager.performAPIRequestJSON(.post, urlSuffix: "/auth/sign_in", params: ["email": email, "password" : password]) { (json, error, res) in
      if (json == nil) {
        return self.showAlert(title: "Error", message: "An error occurred. Please try again.")
      }
      
      if (error != nil) {
        let errors = json!["errors"].array
        if (errors != nil) {
          let errorsString = errors!.map({ (val) -> String in
            return val.stringValue
          }).joined(separator: "\n")
          return self.showAlert(title: errors!.count > 1 ? "Errors" : "Error", message: errorsString)
        }
      }
      
      if !UserSession.sharedInstance.isLoggedIn() {
        return self.showAlert(title: "Error", message: "An unusual error occurred, and we weren't able to log you in. Please try again")
      }
      
      MainTabBarController.presentOnNavigationController(self.navigationController)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
