//
//  allTasksMapViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 30/6/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import MapKit
import os.log
import CoreLocation
import Firebase


class allTasksMapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var tasks = [Tasks]()
    var taskToBeTransferred: Tasks?
    var refTask : DatabaseReference?
     var user:Users?
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager =  CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapConfigure()
        loadTasks()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let tasksRef = Database.database().reference().child("Tasks")
        tasksRef.removeAllObservers()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])  {
        
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        //set region on the map
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        //mapV.centerCoordinate = userLocation.location!.coordinate
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! customAnnotation
        taskToBeTransferred = tasks[annotation.index]
        self.performSegue(withIdentifier: "mapToTask", sender: self)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier){
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else{
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.isEnabled = true
            annotationView.image = UIImage(named: "mapPin.png")
        }
        return annotationView
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as? UINavigationController
        if segue.identifier == "mapToTask" {
            let destinationViewController = navVC?.viewControllers.first as! taskDetailViewController
            destinationViewController.task = taskToBeTransferred
            destinationViewController.user = self.user
        }
    }
    
    //    func loadUser(){
    //
    //        let userRef =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!)
    //
    //        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
    //            // Get user value
    //
    //            if let dictionary = snapshot.value as? [String:AnyObject] {
    //                self.user = Users(dictionary:dictionary)
    //            }
    //            self.loadTasks()
    //        }) { (error) in
    //            print(error.localizedDescription)
    //        }
    //    }
    
    //load the tasks
    
    func loadTasks(){
        
        refTask = Database.database().reference().child("Tasks")
        refTask?.observe(DataEventType.value, with: {(snapshot) in
            
            if snapshot.childrenCount > 0{
                self.tasks.removeAll()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
                
                for tasks in snapshot.children.allObjects as![DataSnapshot] {
                    if let dictionary = tasks.value as? [String:AnyObject]{
                        let task = Tasks(dictionary:dictionary)
                        //filter blocked users
                        var bool = false
                        if let blockedUsers = self.user?.blockedUsers {
                            if  blockedUsers.contains(task.postedUser){
                                bool = true
                            }
                        }
                        
                        if task.assignedTasker == "" && task.dueDate > Date() && !bool {
                            self.tasks.append(task)
                        }
                        
                    }
                    
                }
                self.addAnnotations() // call this function after tasks are fully loaded
            }
        })
        
    }
    
    func mapConfigure(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.delegate = self
    }
    
    func addAnnotations(){
        for task in tasks {
            
            let coordinate = CLLocationCoordinate2D(latitude: task.latitude, longitude: task.longitude)
            let annotation = customAnnotation(coordinate: coordinate)
            annotation.title = task.title
            annotation.subtitle = task.location
            
            let index = tasks.index(of: task)
            annotation.index = index!
            mapView.addAnnotation(annotation)
        }
    }
    
    
}

class customAnnotation: NSObject, MKAnnotation {
    
    var index:Int = 0
    var title: String? = ""
    var subtitle: String? = ""
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    var getCoordinate: CLLocationCoordinate2D {
        return coordinate
    }
}
