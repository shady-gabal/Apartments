//
//  UserDetailViewController.swift
//  Users
//
//  Created by Shady on 7/15/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit
import Eureka
import Alamofire

class UserDetailViewController: FormViewController {
  
  var user:User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(self.submit))
    
    form +++ TextRow(){ row in
      row.title = "Name"
      row.tag = "name"
      row.value = self.user?.name
      row.add(rule: RuleRequired(msg: row.title! + " required"))
      }
    <<< TextRow(){ row in
      row.title = "Email"
      row.tag = "email"
      row.value = self.user?.email
      row.add(rule: RuleRequired(msg: row.title! + " required"))
      row.add(rule: RuleEmail(msg: row.title! + " must be an email"))
    }
    <<< PasswordRow() { row in
      row.title = "Password"
      row.tag = "password"
    }
    <<< PushRow<String>() { row in
      row.title = "Role"
      row.tag = "role"
      row.options = [Role.Client.rawValue, Role.Realtor.rawValue, Role.Admin.rawValue]
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
  }
  
  @objc func submit() {
    let errors = form.validate()
    
    if errors.count == 0 {
      var userVals = form.values()
      let userParams = userVals.mapValues { (val) -> Any in
        return val ?? nil
      }
      
      let password = userVals["password"] as! String?
      if password == nil || password!.isEmpty {
        userVals.removeValue(forKey: "password")
      }
      
      var urlSuffix = "/users"
      var method = Alamofire.HTTPMethod.post
      
      if self.user != nil {
        method = Alamofire.HTTPMethod.patch
        urlSuffix += "/\(self.user!.id)"
      }
      
      NetworkManager.performAPIRequestJSON(method, urlSuffix: urlSuffix, params: ["user": userParams]) { (json, error) in
        if error != nil || json == nil {
          if let jsonErrors = json?["errors"].array {
            let errorsString = jsonErrors.map({ (val) -> String in
              return val.stringValue
            }).joined(separator: "\n")
            
            return self.showAlert(title: "Error", message: errorsString)
          }
          
          return self.showAlert(title: "Error", message: "An error occurred. Please try again.")
        }
        
        let decoder = JSONDecoder()
        if let user = try? decoder.decode(User.self, from: json!.rawData()) {
          UsersStore.sharedInstance.setUser(user)
          self.navigationController?.popViewController(animated: true)
        }
        else {
          self.showAlert(title: "Error", message: "An error occurred. Please try again.")
        }
      }
    }
    else {
      let errorsString = errors.map({ (val) -> String in
        return val.msg
      }).joined(separator: "\n")
      
      self.showAlert(title: "Error", message: errorsString)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
