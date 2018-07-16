//
//  RegisterViewController.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  
  @IBOutlet weak var nameFIeld: UITextField!
  
  @IBOutlet weak var emailField: UITextField!
  
  @IBOutlet weak var passwordField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func registerButtonTapped(_ sender: Any) {
    let email = emailField.text ?? ""
    let password = passwordField.text ?? ""
    let name = nameFIeld.text ?? ""
    
    if name.isEmpty {
      return self.showAlert(title: "Error", message: "Please enter your name.")
    }
    else if email.isEmpty {
      return self.showAlert(title: "Error", message: "Please enter an email.")
    }
    else if password.isEmpty {
      return self.showAlert(title: "Error", message: "Please enter a password.")
    }
    
    NetworkManager.performAPIRequestJSON(.post, urlSuffix: "/auth", params: ["name": name, "email": email, "password" : password ]) { (json, error) in
      if json == nil {
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
  
}
