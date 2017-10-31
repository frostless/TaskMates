//  locationViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 6/14/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class locationViewController: UIViewController,UISearchBarDelegate {
    
    var selectedPin: MKPlacemark?
    
    var resultSearchController: UISearchController!
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController:locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "请输入任务地址"
        searchBar.setValue("取消", forKey:"_cancelButtonText")
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        searchBar.delegate = self
        
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    /*
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (navigationItem.rightBarButtonItem != nil) {
            
            navigationItem.rightBarButtonItem = nil
            
        }
     
        return true
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if (navigationItem.rightBarButtonItem != nil) {
            
            navigationItem.rightBarButtonItem = nil
            
        }
        
    }
   
    */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if (navigationItem.rightBarButtonItem != nil) {
            
            navigationItem.rightBarButtonItem = nil
            
        }
        
    }
 
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        
          navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(goBack))
        
        if (navigationItem.rightBarButtonItem != nil && resultSearchController!.searchBar.text == "") {
            
            navigationItem.rightBarButtonItem = nil
            
        }
    }
    
    
    @objc func goBack(){
        
        if(resultSearchController!.searchBar.text != ""){
        
           performSegue(withIdentifier: "back", sender: self)
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.identifier == "back") {
            
            if let destinationViewController = segue.destination as? newTasksViewController {
                destinationViewController.taskLocation = resultSearchController!.searchBar.text
               
                if let location = selectedPin {
                    
                    destinationViewController.taskLatitude = location.coordinate.latitude
                     destinationViewController.taskLongitude = location.coordinate.longitude
                }
 
            }
        }
    }
    
}


extension locationViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

extension locationViewController : HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        resultSearchController!.searchBar.text = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}
