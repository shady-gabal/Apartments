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
import Alamofire

class UsersTableViewController: AZTableViewController, UITableViewDelegate, UITableViewDataSource {
  
  let cellIdentifier = "UsersTableViewCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.noResults = nil
    self.loadingView = nil
    self.fetchData()
  }
  
  override func fetchData() {
    super.fetchData()
    UsersStore.sharedInstance.fetchUsers(excludedIds:UsersStore.sharedInstance.userIds(), completion:self.fetchDataCallback(resultCount:error:res:))
  }
  
  func fetchDataCallback(resultCount:Int, error: Error?, res:DataResponse<Any>) {
    if error == nil {
      self.setNavigationItemButtons()
      self.didfetchData(resultCount: resultCount, haveMoreData: resultCount != 0)
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
  
  @objc func refreshAllUsers() {
    UsersStore.sharedInstance.refreshAllUsers(completion: self.fetchDataCallback(resultCount:error:res:))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavigationItemButtons()
  }
  
  func setNavigationItemButtons(hide:Bool = false) {
    self.setRefreshButton(hide: hide)
    self.setAddButton(hide: hide)
  }
  
  func setRefreshButton(hide:Bool = false) {
    self.tabBarController?.navigationItem.leftBarButtonItem = hide ? nil : UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAllUsers))
  }
  
  func setAddButton(hide:Bool = false) {
    var item:UIBarButtonItem? = nil
    if !hide && UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue {
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
  
  @objc private func createButtonTapped() {
    let detail = UserDetailViewController()
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return (UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue {
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
