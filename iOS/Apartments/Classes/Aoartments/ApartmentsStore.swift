//
//  ApartmentsStore.swift
//  Apartments
//
//  Created by Shady on 7/9/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation
import SwiftyJSON

class ApartmentsStore {
  static let sharedInstance = ApartmentsStore()
  private var apartments:[Apartment] = []
  private var availableRealtorEmails:[String] = []
  
  init() { }
  
  func apartmentIds() -> [Int] {
    return apartments.map({ (apt) -> Int in
      return apt.id
    })
  }
  
  func setApartment(_ apt:Apartment) {
    for i in 0..<apartments.count {
      if apartments[i].id == apt.id {
        apartments[i] = apt
        break
      }
    }
  }
  
  func removeApartment(_ apt:Apartment) {
    for i in 0..<self.apartments.count {
      if self.apartments[i].id == apt.id {
        self.apartments.remove(at: i)
        break
      }
    }
  }
  
  func getApartments() -> [Apartment] {
    return self.apartments
  }
  
  func getApartmentWithId(_ id:Int) -> Apartment? {
    return self.apartments.first(where: { (apt) -> Bool in
      return apt.id == id
    })
  }
  
  func getAvailableRealtorEmails() -> [String] {
    return availableRealtorEmails
  }
  
  func setAvailableRealtorEmails(_ emails:[String]) {
    self.availableRealtorEmails = emails
  }
  
  func deleteApartment(_ apt:Apartment, completion: @escaping (Bool, Error?) -> Void) {
    NetworkManager.performAPIRequestJSON(.delete, urlSuffix: "/apartments/\(apt.id)", params: [:]) { (json, error, res) in
      if json != nil && error == nil {
        self.removeApartment(apt)
        completion(true, error)
      }
      else {
        completion(false, error)
      }
    }
  }
  
  public func refreshAllApartments(_ filters:[String:[String]], completion: @escaping (Int, Error?)->Void) {
    self.apartments = []
    self.fetchApartmentsWithFilters(filters, excludedIds: [], completion: completion)
  }
  
  public func fetchApartmentsWithFilters(_ filters:[String:[String]], excludedIds:[Int], completion: @escaping (Int, Error?)->Void) {
    NetworkManager.performAPIRequestJSON(.get, urlSuffix: "/apartments", params: ["excluded_ids": excludedIds, "filters": filters], completion: { (json, error, res) in
      if error != nil || json == nil {
        return completion(0, error)
      }
      
      let decoder = JSONDecoder()
      var resultCount:Int = 0
      
      UserSession.sharedInstance.apartmentsPermissions = Utils.permissionsFromString(json!["permissions"].stringValue)
        
      let apartmentsArrayData = json!["data"]
      let apartments = try? decoder.decode([Apartment].self, from: apartmentsArrayData.rawData())
      if apartments != nil {
        ApartmentsStore.sharedInstance.apartments += apartments!
        resultCount += apartments!.count
      }
      
      let realtorEmails = json!["availableRealtorEmails"].arrayValue.map({ (emailJson) -> String in
        return emailJson.stringValue
      })
      self.setAvailableRealtorEmails(realtorEmails)
    
      completion(resultCount, error)
    })
  }
}
