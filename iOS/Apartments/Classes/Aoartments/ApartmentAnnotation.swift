//
//  ApartmentAnnotation.swift
//  Apartments
//
//  Created by Shady on 7/17/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit
import MapKit

class ApartmentAnnotation: MKPointAnnotation {
  var apartmentId:Int
  
  init(apartmentId:Int) {
    self.apartmentId = apartmentId
  }
}
