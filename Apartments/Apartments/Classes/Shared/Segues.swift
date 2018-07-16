//
//  DismissSegue.swift
//  Apartments
//
//  Created by Shady on 7/10/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
  override func perform() {
    if let p = source.presentingViewController {
      p.dismiss(animated: true, completion: nil)
    }
  }
}

class PresentDashboardSegue: UIStoryboardSegue {
  override func perform() {
    if let p = source.presentingViewController {
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController")
      p.present(viewController, animated: true, completion: nil)
    }
  }
}
