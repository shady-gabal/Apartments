//
//  UsersStore.swift
//  Apartments
//
//  Created by Shady on 7/14/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation
import Alamofire

class UsersStore {
  static let sharedInstance = UsersStore()
  private var users:[User] = []
  
  init() { }
  
  func userIds() -> [Int] {
    return users.map({ (usr) -> Int in
      return usr.id
    })
  }
  
  func getUsers() -> [User] {
    return self.users
  }
  
  func setUser(_ usr:User) {
    for i in 0..<users.count {
      if users[i].id == usr.id {
        users[i] = usr
        break
      }
    }
  }
  
  func removeUser(_ usr:User) {
    for i in 0..<self.users.count {
      if self.users[i].id == usr.id {
        self.users.remove(at: i)
        break
      }
    }
  }
  
  func deleteUser(_ usr:User, completion: @escaping (Bool, Error?) -> Void) {
    NetworkManager.performAPIRequestJSON(.delete, urlSuffix: "/users/\(usr.id)", params: [:]) { (json, error, res) in
      if json != nil && error == nil {
        self.removeUser(usr)
        completion(true, error)
      }
      else {
        completion(false, error)
      }
    }
  }
  
  public func fetchUsers(completion: @escaping (Int, Error?, DataResponse<Any>)->Void) {
    let excludedIds = self.userIds()
    NetworkManager.performAPIRequestJSON(.get, urlSuffix: "/users", params: ["excluded_ids": excludedIds], completion: { (json, error, res) in
      if error != nil || json == nil {
        return completion(0, error, res)
      }
      
      let decoder = JSONDecoder()
      var resultCount:Int = 0

      UserSession.sharedInstance.usersPermissions = Utils.permissionsFromString(json!["permissions"].stringValue)
      
      let users = try? decoder.decode([User].self, from: json!["data"].rawData())
      if users != nil {
        UsersStore.sharedInstance.users = users!
        resultCount += users!.count
      }
      
      completion(resultCount, error, res)
    })
  }
}
