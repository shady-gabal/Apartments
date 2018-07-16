//
//  UserSession.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation
import Strongbox
import SwiftyJSON

enum Permission:Int {
  case CRUD = 3
  case View = 2
  case None = 1
  case Unknown = 0
}

class UserSession {
  static let sharedInstance = UserSession()
  static let AccessTokenArchiveKey = "access_token_archive_key"
  
  private var tokenData:[String: String]?
  private let strongbox = Strongbox()
  var apartmentsPermissions:Permission = Permission.Unknown
  var usersPermissions:Permission = Permission.Unknown
  
  init() {
    if let accessTokenData = self.strongbox.unarchive(objectForKey: UserSession.AccessTokenArchiveKey) as? [String:String] {
      self.tokenData = accessTokenData
    }
  }
  
  func isLoggedIn() -> Bool {
    return tokenData != nil
  }
  
  func getTokenDataHeaders() -> [String:String]? {
    return tokenData
  }
  
  func setTokenData(tokenData:[String: String]) -> Bool {
    if let _ = tokenData["access-token"] {
      self.tokenData = [ "uid": tokenData["uid"] ?? "", "client": tokenData["client"] ?? "", "access-token": tokenData["access-token"] ?? "", "token-type": tokenData["token-type"] ?? "" ]
      if (self.tokenData!.count > 0 && self.strongbox.archive(self.tokenData, key: UserSession.AccessTokenArchiveKey)) {
          return true
      }
    }

    return false
  }
  
  func logout() {
    self.tokenData = nil
    _ = self.strongbox.remove(key: UserSession.AccessTokenArchiveKey)
  }
  
//  func setLoggedInUser(userData:Data?) -> Bool {
//    if userData == nil {
//      return false
//    }
//    
//    let decoder = JSONDecoder()
//    loggedInUser = try? decoder.decode(User.self, from: userData!)
//    return loggedInUser != nil
//  }
}
