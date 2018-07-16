//
//  ApartmentDetailViewController.swift
//  Apartments
//
//  Created by Shady on 7/15/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit
import Eureka
import Alamofire

class ApartmentDetailViewController: FormViewController {

  var apartment:Apartment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if UserSession.sharedInstance.usersPermissions.rawValue >= Permission.CRUD.rawValue {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(submit))
    }
    
    form +++ TextRow(){ row in
      row.title = "Name"
      row.tag = "name"
      row.value = self.apartment?.name
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< DecimalRow(){ row in
      row.title = "Floor area size"
      row.tag = "floor_area_size"
      row.value = self.apartment?.floorAreaSize
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< DecimalRow(){ row in
      row.title = "Price per month"
      row.tag = "price_per_month"
      row.value = self.apartment?.pricePerMonth
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< IntRow(){ row in
      row.title = "Number of rooms"
      row.tag = "number_of_rooms"
      row.value = self.apartment?.numberOfRooms
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< TextRow(){ row in
      row.title = "Description"
      row.tag = "description"
      row.value = self.apartment?.description
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< DecimalRow(){ row in
      row.title = "Lat"
      row.tag = "lat"
      row.value = self.apartment?.lat
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< DecimalRow(){ row in
      row.title = "Lon"
      row.tag = "lon"
      row.value = self.apartment?.lon
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
    <<< SwitchRow(){ row in
      row.title = "Rented"
      row.tag = "rented"
      row.value = self.apartment?.rented
    }
    <<< PushRow<String>() { row in
      row.title = "Realtor"
      row.tag = "realtor"
      row.options = ApartmentsStore.sharedInstance.getAvailableRealtorEmails()
      row.add(rule: RuleRequired(msg: row.title! + " required"))
    }
  }

  @objc func submit() {
    if UserSession.sharedInstance.usersPermissions.rawValue < Permission.CRUD.rawValue {
      return
    }
    
    let errors = form.validate()
    
    if errors.count == 0 {
      let apartmentVals = form.values()
      var urlSuffix = "/apartments"
      var method = Alamofire.HTTPMethod.post
      
      if self.apartment != nil {
        method = Alamofire.HTTPMethod.patch
        urlSuffix += "/\(self.apartment!.id)"
      }
      
      NetworkManager.performAPIRequestJSON(method, urlSuffix: urlSuffix, params: ["apartment": apartmentVals]) { (json, error) in
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
        if let apartment = try? decoder.decode(Apartment.self, from: json!.rawData()) {
          ApartmentsStore.sharedInstance.setApartment(apartment)
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
