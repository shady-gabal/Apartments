//
//  MainTabBarController.swift
//  Apartments
//
//  Created by Shady on 7/14/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    static func presentOnNavigationController(_ nav: UINavigationController?) {
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController")
      nav?.setViewControllers([viewController], animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
