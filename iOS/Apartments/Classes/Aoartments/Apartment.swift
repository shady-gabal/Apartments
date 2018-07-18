//
//  Apartment.swift
//  Apartments
//
//  Created by Shady on 7/9/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation

struct Apartment : Codable {
  var id:Int
  var name:String
  var description:String
  var floorAreaSize:Double
  var pricePerMonth:Double
  var numberOfRooms:Int
  var lat:Double
  var lon:Double
  var rented:Bool
  var realtor:String?
}
