//
//  UsersTableViewController.swift
//  Apartments
//
//  Created by Shady on 7/15/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit
import AZTableView
import MapKit

class UsersTableViewController: AZTableViewController, UITableViewDelegate, UITableViewDataSource {
  
  let cellIdentifier = "UsersTableViewCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.noResults = nil

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(createButtonTapped))
    self.fetchData()
  }
  
  override func fetchData() {
    super.fetchData()
    
    UsersStore.sharedInstance.fetchUsers { (resultCount, error, res) in
      if error == nil {
        self.setAddButton()
        self.didfetchData(resultCount: resultCount, haveMoreData: resultCount != 0)
//        self.tableView?.reloadData()
      }
      else {
        if let statusCode = res.response?.statusCode {
          if statusCode == 401 {
            return self.didfetchData(resultCount: 0, haveMoreData: false)
          }
        }
        self.errorDidOccured(error: error)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setAddButton()
  }
  
  func setAddButton() {
    var item:UIBarButtonItem? = nil
    if UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue {
      item = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.createButtonTapped))
    }
    self.tabBarController?.navigationItem.rightBarButtonItem = item
  }
  
  override func fetchNextData() {
    super.fetchNextData()
    self.fetchData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func AZtableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return UsersStore.sharedInstance.getUsers().count
  }
  
  override func AZtableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let user = UsersStore.sharedInstance.getUsers()[indexPath.row]
    cell.textLabel?.text = user.email
    cell.detailTextLabel?.text = user.role
    
    return cell
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    if (UserSession.sharedInstance.usersPermissions.rawValue >= Permission.View.rawValue) {
      return 1
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detail = UserDetailViewController()
    detail.user = UsersStore.sharedInstance.getUsers()[indexPath.row]
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
  @objc func createButtonTapped() {
    let detail = UserDetailViewController()
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return (UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.CRUD.rawValue {
      let usr = UsersStore.sharedInstance.getUsers()[indexPath.row]
      UsersStore.sharedInstance.deleteUser(usr) { (success, error) in
        if !success {
          self.showAlert(title: "Error", message: "There was an error deleting this user. Please try again.")
        }
        else {
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    }
  }
}
