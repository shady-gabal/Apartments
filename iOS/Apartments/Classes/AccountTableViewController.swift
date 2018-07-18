//
//  AccountTableViewController.swift
//  Apartments
//
//  Created by Shady on 7/13/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {

    override func viewDidLoad() {
      super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func logout(_ sender: Any) {
      UserSession.sharedInstance.logout()
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
      self.navigationController?.setViewControllers([viewController], animated: true)
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.tabBarController?.navigationItem.rightBarButtonItem = nil
      self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
}
