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

typealias Filter = (Double,Double?)

class ApartmentsTableViewController: AZTableViewController, UITableViewDelegate, UITableViewDataSource, DOPDropDownMenuDelegate, DOPDropDownMenuDataSource, MKMapViewDelegate {
  
  enum FilterColumn:Int {
    case Size = 0
    case Price = 1
    case NumRooms = 2
    case TotalColumns = 3
  }
  
  @IBOutlet weak var filtersContainerView: UIView!
  @IBOutlet weak var mapView: MKMapView!
  
  let filterColumnSizeOptions:[Filter] = [(1,500), (501,1000), (1001,2000), (2001,3000), (3001,4000), (4001, nil)]
  let filterColumnPriceOptions:[Filter] = [(1,1000), (1001,1500), (1501,2000), (2001,2500), (2501,3000), (3001,3500)]
  let filterColumnNumRoomsOptions:[Filter] = [(1,1),(2,2),(3,3),(4,4),(5,nil)]
  
  var filters:[FilterColumn:Filter] = [:]
  
  let cellIdentifier = "ApartmentsTableViewCell"
  
  private var apartmentsMatchingFilters:[Apartment] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.noResults = nil

    let menuViewOrigin = (self.navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height
    
    if let menuView = DOPDropDownMenu.init(origin: CGPoint(x: 0, y: menuViewOrigin), andHeight: self.filtersContainerView.frame.size.height) {
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
        self.reloadTableView()
      }
      else {
        self.errorDidOccured(error: error)
      }
    }
  }
  
  func reloadTableView() {
    self.setApartmentsMatchingFilters()
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.apartmentsMatchingFilters.forEach { (apt) in
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: apt.lat, longitude: apt.lon)
      annotation.title = apt.name
      mapView.addAnnotation(annotation)
    }
    self.tableView?.reloadData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setAddButton()
  }
  
  func setApartmentsMatchingFilters() {
    self.apartmentsMatchingFilters = ApartmentsStore.sharedInstance.getApartments().filter({ (apt) -> Bool in
      
      for (column,filter) in self.filters {
        var val:Double = 0
        
        if column.rawValue == FilterColumn.Size.rawValue {
          val = apt.floorAreaSize
        }
        else if column.rawValue == FilterColumn.Price.rawValue {
          val = apt.pricePerMonth
        }
        else if column.rawValue == FilterColumn.NumRooms.rawValue {
          val = Double(apt.numberOfRooms)
        }
        else {
          return false
        }
        
        let min = filter.0
        let max = filter.1 ?? Double.infinity
        let satisfies = (val <= max && val >= min)
        
        if !satisfies {
          return false
        }
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
    return self.apartmentsMatchingFilters.count
  }

  override func AZtableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let apartment = self.apartmentForIndexPath(indexPath)
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
  
  func apartmentForIndexPath(_ indexPath:IndexPath) -> Apartment {
    return self.apartmentsMatchingFilters[indexPath.row]
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
      let apt = self.apartmentForIndexPath(indexPath)
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
  
  // MARK: - Filter Menu Delegate
  
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
    if let filter = self.filterForIndexPath(indexPath) {
      if filter.1 == nil {
        return "\(filter.0)+"
      }
      else if filter.0 == filter.1 {
        return "\(filter.0)"
      }
      
      return "\(filter.0)-\(filter.1!)"
    }
    else {
      if indexPath.column == FilterColumn.Size.rawValue {
        return "All Sizes"
      }
      else if indexPath.column == FilterColumn.Price.rawValue {
        return "All Prices"
      }
      else if indexPath.column == FilterColumn.NumRooms.rawValue {
        return "All Rooms"
      }
    }
    
    return ""
  }
  
  func menu(_ menu: DOPDropDownMenu!, didSelectRowAt indexPath: DOPIndexPath!) {
    if let column = FilterColumn(rawValue: indexPath.column) {
      if let filter = self.filterForIndexPath(indexPath) {
        self.filters[column] = filter
      }
      else {
        self.filters.removeValue(forKey: column)
      }
      
      self.reloadTableView()
    }
  }
  
  func filterForIndexPath(_ indexPath:DOPIndexPath) -> Filter? {
    if (indexPath.row == 0) {
      return nil
    }
    
    var arrayToUse:[Filter]?
    if indexPath.column == FilterColumn.Size.rawValue {
      arrayToUse = filterColumnSizeOptions
    }
    else if indexPath.column == FilterColumn.Price.rawValue {
      arrayToUse = filterColumnPriceOptions
    }
    else if indexPath.column == FilterColumn.NumRooms.rawValue {
      arrayToUse = filterColumnNumRoomsOptions
    }
    else {
      return nil
    }
    
    return arrayToUse![indexPath.row-1]
  }
  
  @objc func createButtonTapped() {
    let detail = ApartmentDetailViewController()
    self.navigationController?.pushViewController(detail, animated: true)
  }
}
