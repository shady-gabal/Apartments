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
import DOPDropDownMenu

class ApartmentsTableViewController: AZTableViewController, UITableViewDelegate, UITableViewDataSource, DOPDropDownMenuDelegate, DOPDropDownMenuDataSource {
  
  enum FilterColumn:Int {
    case Size = 0
    case Price = 1
    case NumRooms = 2
    case TotalColumns = 3
  }
  let filterColumnSizeOptions = [500, 1000, 2000, 3000, 4000, 5000]
  let filterColumnPriceOptions = [1000, 1500, 2000, 2500, 3000, 3500]
  let filterColumnNumRoomsOptions = [1,2,3,4,5]
  
  var sizeFilter:Int?
  var priceFilter:Int?
  var numRoomsFilter:Int?

  let cellIdentifier = "ApartmentsTableViewCell"
  
  static let ApartmentsMapViewHeight:CGFloat = 150
  static let ApartmentsFilterViewHeight:CGFloat = 50
  
  private var apartmentsMatchingFilters:[Apartment] = []
  
  @IBOutlet weak var filtersContainerView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.noResults = nil
    
    let menuViewOrigin = (self.navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height
    
    if let menuView = DOPDropDownMenu.init(origin: CGPoint(x: 0, y: menuViewOrigin), andHeight: ApartmentsTableViewController.ApartmentsFilterViewHeight) {
      menuView.delegate = self
      menuView.dataSource = self
      self.view.addSubview(menuView)
    }
    
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
  
  func setApartmentsMatchingFilters() {
    self.apartmentsMatchingFilters = ApartmentsStore.sharedInstance.getApartments().filter({ (apt) -> Bool in
      if sizeFilter != nil {
        
      }
      if priceFilter != nil {
        
      }
      
      if numRoomsFilter != nil {
        
      }
      
      return true
    })
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
    let mapView = MKMapView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: ApartmentsTableViewController.ApartmentsMapViewHeight))
    
    ApartmentsStore.sharedInstance.getApartments().forEach { (apt) in
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: apt.lat, longitude: apt.lon)
      annotation.title = apt.name
      mapView.addAnnotation(annotation)
    }

    return mapView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return ApartmentsTableViewController.ApartmentsMapViewHeight + ApartmentsTableViewController.ApartmentsFilterViewHeight
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
  
  func numberOfColumns(in menu: DOPDropDownMenu!) -> Int {
    return FilterColumn.TotalColumns.rawValue
  }
  
  func menu(_ menu: DOPDropDownMenu!, numberOfRowsInColumn column: Int) -> Int {
    if column == FilterColumn.Size.rawValue {
      return filterColumnSizeOptions.count + 1
    }
    else if column == FilterColumn.Price.rawValue {
      return filterColumnPriceOptions.count + 1
    }
    else if column == FilterColumn.NumRooms.rawValue {
      return filterColumnNumRoomsOptions.count + 1
    }
    
    return 1
  }
  
  func menu(_ menu: DOPDropDownMenu!, titleForRowAt indexPath: DOPIndexPath!) -> String! {
    var option:Int?
    var prefix:String = "<"
    
    if indexPath.column == FilterColumn.Size.rawValue {
      if indexPath.row == 0 {
        return "All Sizes"
      }
      else {
        option = filterColumnSizeOptions[indexPath.row-1]
      }
    }
    else if indexPath.column == FilterColumn.Price.rawValue {
      if indexPath.row == 0 {
        return "All Prices"
      }
      else {
        option = filterColumnPriceOptions[indexPath.row-1]
      }
    }
    else if indexPath.column == FilterColumn.NumRooms.rawValue {
      if indexPath.row == 0 {
        return "All Rooms"
      }
      else {
        prefix = ""
        option = filterColumnNumRoomsOptions[indexPath.row-1]
      }
    }
    
    if let filter = option {
      if self.menu(menu, numberOfRowsInColumn: indexPath.column) == indexPath.row + 1 {
        return "\(filter)+"
      }
      else {
        return "\(prefix)\(filter)"
      }
    }
    
    return ""
  }
  
  func menu(_ menu: DOPDropDownMenu!, didSelectRowAt indexPath: DOPIndexPath!) {
    var arrayToUse:[Int]?
    
    if indexPath.column == FilterColumn.Size.rawValue {
      arrayToUse = filterColumnSizeOptions
    }
    else if indexPath.column == FilterColumn.Price.rawValue {
      arrayToUse = filterColumnPriceOptions
    }
    else if indexPath.column == FilterColumn.NumRooms.rawValue {
      arrayToUse = filterColumnNumRoomsOptions
    }
    
    
    setApartmentsMatchingFilters()
    self.tableView?.reloadData()
  }
  
  
  @objc func createButtonTapped() {
    let detail = ApartmentDetailViewController()
    self.navigationController?.pushViewController(detail, animated: true)
  }
}
