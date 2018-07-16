//
//  ApartmentsTableViewController.swift
//  Apartments
//
//  Created by Shady on 7/13/18.
//  Copyright © 2018 Shady Gabal. All rights reserved.
//

import UIKit
import AZTableView
import MapKit

class ApartmentsTableViewController: AZTableViewController, UITableViewDelegate, UITableViewDataSource {
  
  let cellIdentifier = "ApartmentsTableViewCell"
  
  static let ApartmentsMapViewHeight:CGFloat = 200
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.noResults = nil
    self.fetchData()
  }

  override func fetchData() {
    super.fetchData()

    ApartmentsStore.sharedInstance.fetchApartments { (resultCount, error) in
      if error == nil {
        self.setAddButton()
        self.didfetchData(resultCount: resultCount, haveMoreData: resultCount != 0)
        self.tableView?.reloadData()
      }
      else {
        self.errorDidOccured(error: error)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setAddButton()
  }
  
  func setAddButton() {
    var item:UIBarButtonItem? = nil
    if UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.CRUD.rawValue {
      item = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.createButtonTapped))
    }
    self.tabBarController?.navigationItem.rightBarButtonItem = item
  }
  
  override func fetchNextData() {
    super.fetchNextData()
    self.fetchData()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  override func AZtableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ApartmentsStore.sharedInstance.getApartments().count
  }

  override func AZtableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let apartment = ApartmentsStore.sharedInstance.getApartments()[indexPath.row]
    cell.textLabel?.text = apartment.name
    cell.detailTextLabel?.text = apartment.rented ? "Rented" : "Rentable"
    
    return cell
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    if (UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.View.rawValue) {
      return 1
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let mapView = MKMapView.init(frame: CGRect(x: 0, y: 0, width: 300, height: ApartmentsTableViewController.ApartmentsMapViewHeight))
    
    ApartmentsStore.sharedInstance.getApartments().forEach { (apt) in
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: apt.lat, longitude: apt.lon)
      annotation.title = apt.name
      mapView.addAnnotation(annotation)
    }
    
    return mapView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return ApartmentsTableViewController.ApartmentsMapViewHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detail = ApartmentDetailViewController()
    detail.apartment = ApartmentsStore.sharedInstance.getApartments()[indexPath.row]
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return (UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.View.rawValue)
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return (UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.View.rawValue)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && UserSession.sharedInstance.apartmentsPermissions.rawValue >= Permission.CRUD.rawValue {
      let apt = ApartmentsStore.sharedInstance.getApartments()[indexPath.row]
      ApartmentsStore.sharedInstance.deleteApartment(apt) { (success, error) in
        if !success {
          self.showAlert(title: "Error", message: "There was an error deleting this apartment. Please try again.")
        }
        else {
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    }
  }
  
  @objc func createButtonTapped() {
    let detail = ApartmentDetailViewController()
    self.navigationController?.pushViewController(detail, animated: true)
  }
}
