//
//  NetworkManager.swift
//  Apartments
//
//  Created by Shady on 7/9/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager: NSObject {
  
  static let ApiBaseUrl:String = "https://shadyg.ngrok.io/api/v1"
  
  static func performAPIRequestJSON(_ method: Alamofire.HTTPMethod, urlSuffix:String, params:[String : Any], completion: @escaping (JSON?, Error?, DataResponse<Any>) -> Void) {
    let url = NetworkManager.ApiBaseUrl + urlSuffix
    var headers: HTTPHeaders = [:]

    if (UserSession.sharedInstance.isLoggedIn()) {
      headers = UserSession.sharedInstance.getTokenDataHeaders()!
    }
    
    Alamofire.request(url, method: method, parameters: params, headers: headers).validate()
      .responseJSON(completionHandler: {(response) -> Void in
        if let headers = response.response?.allHeaderFields as? [String:String] {
          if let token = headers["access-token"] {
            if !token.isEmpty {
              _ = UserSession.sharedInstance.setTokenData(tokenData: headers)
            }
          }
        }
        
        var jsonResponse:JSON? = response.result.value == nil ? JSON.null : JSON(response.result.value!)
        if response.data != nil && jsonResponse == JSON.null {
          jsonResponse = JSON(response.data!)
        }
        
        if response.result.isFailure {
          completion(jsonResponse == JSON.null ? nil : jsonResponse, response.result.error, response)
        }
        else{
          completion(jsonResponse == JSON.null ? nil : jsonResponse, nil, response)
        }
      })
  }
}
