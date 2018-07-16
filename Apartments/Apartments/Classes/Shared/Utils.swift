//
//  Utils.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation

class Utils {
  static func permissionsFromString(_ perms:String) -> Permission {
    if perms == "crud" {
      return Permission.CRUD
    }
    else if perms == "view" {
      return Permission.View
    }
    else if perms == "none" {
      return Permission.None
    }
    else {
      return Permission.Unknown
    }
  }
}
