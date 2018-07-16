//
//  User.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation

enum Role:String {
  case Realtor = "realtor"
  case Client = "client"
  case Admin = "admin"
}

struct User : Codable {
  var id:Int
  var email:String
  var role:String
  var name:String
}
