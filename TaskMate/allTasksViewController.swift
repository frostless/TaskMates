//
//  allTasksViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 6/21/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import Firebase
import Kingfisher

class allTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    //MARK: Properties
    
    let locationManager = CLLocationManager()
    var myLocation = CLLocation()
    //var task: Tasks?
    var refTask : DatabaseReference?
    var user:Users?
    var tasks = [Tasks]()
    var tasksTemp = [Tasks]()
    var taskToBeTransferred: Tasks?
    var searchController: UISearchController!
    
    var shouldShowRedDot:Bool?
    var  redDot:UIView?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadUser()
        loacationManagerConfigure()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        redDot?.removeFromSuperview()//disappear redDot
        shouldShowRedDot = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        shouldShowRedDot = true
    }
    
    deinit {
        Database.database().reference().child("Tasks").removeAllObservers()
       
    }
    
    func addRedDotAtTabBarItemIndex(index:Int) {
        
        if shouldShowRedDot == false {
            return
        }
        //dont add more than necessary
        if let redDot = self.redDot,let tabBar = tabBarController?.tabBar {
            if redDot.isDescendant(of: tabBar){
                return
            }
        }
        let itemFrame = self.tabBarController!.tabBar.subviews[index+1].frame
        
        let startX = itemFrame.origin.x + 0.6*itemFrame.width
        let startY = itemFrame.origin.y + 5
        
        let RedDotRadius: CGFloat = 5
        let RedDotDiameter = RedDotRadius * 2
        
        //        let TopMargin:CGFloat = 5
        
        //        let TabBarItemCount = CGFloat(self.tabBarController!.tabBar.items!.count)
        //
        //        let HalfItemWidth = view.bounds.width / (TabBarItemCount * 2)
        //
        //        let  xOffset = HalfItemWidth * CGFloat(index * 2 + 1)
        //
        //        let imageHalfWidth: CGFloat = (self.tabBarController!.tabBar.items![index]).selectedImage!.size.width / 2
        //
        //        redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
        redDot = UIView(frame: CGRect(x: startX, y: startY , width: RedDotDiameter, height: RedDotDiameter))
        
        redDot?.backgroundColor = UIColor.red
        redDot?.layer.cornerRadius = RedDotRadius
        tabBarController?.tabBar.addSubview(redDot!)
        
    }
    
    
    @IBAction func segueToMapTasks(_ sender: Any) {
        self.performSegue(withIdentifier: "allTasksToMap", sender: self)
    }
    
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        //searchController.isActive = true
        searchController = UISearchController(searchResultsController: nil)
        // Set any properties (in this case, don't hide the nav bar and don't show the emoji keyboard option)
        searchController.hidesNavigationBarDuringPresentation = false
        // Make this class the delegate and present the search
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "搜索"
        searchBar.setValue("取消", forKey:"_cancelButtonText")
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    @IBAction func sortSearchResults(_ sender: Any, forEvent event: UIEvent) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
                let sortByBudgetAction = UIAlertAction(title: "按价钱", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
        
                    self.tasks = self.tasks.sorted(by: { $0.budget > $1.budget })
                    self.tableView.reloadData()
                })
        
                let sortByDateAction = UIAlertAction(title: "按创建日期", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
        
                    self.tasks = self.tasks.sorted(by: { $0.createdDate > $1.createdDate })
                    self.tableView.reloadData()
                })
        
                let sortByDistanceAction = UIAlertAction(title: "按距离", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
        
                    self.tasks = self.tasks.sorted(by: { $0.distance(to: self.myLocation) < $1.distance(to: self.myLocation) })
                    self.tableView.reloadData()
        
                })
        
                let sortByDueTime = UIAlertAction(title: "按完成时间", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
        
                    self.tasks = self.tasks.sorted(by: { $0.dueDate > $1.dueDate })
                    self.tableView.reloadData()
                })
        
           let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
                optionMenu.addAction(sortByBudgetAction)
                optionMenu.addAction(sortByDateAction)
                optionMenu.addAction(sortByDistanceAction)
                optionMenu.addAction(sortByDueTime)
        
        optionMenu.addAction(cancelAction )
        
        //for ipad
        if let popoverPresentationController = optionMenu.popoverPresentationController {
            
            if let touch = event.touches(for: sender as! UIView)?.first{
                // print the touch location on the button
                let locationX = touch.location(in: self.view).x
                let locationY = touch.location(in: self.view).y
                
                popoverPresentationController.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: locationX, y: locationY, width: 1.0, height: 1.0)
                self.present(optionMenu, animated: true, completion: nil)
                return
                
            }
        }

                self.present(optionMenu, animated: true, completion: nil)

    }
    

    
    //MARK: searchbar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        if searchText.isEmpty || searchText == " "{
            tasks = tasksTemp
        }else{
            tasks = tasks.filter(
                { (t) -> Bool in
                    return t.title.contains(searchText)
            })
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allTasksCellTableViewCell", for: indexPath) as? allTasksCellTableViewCell else {
            fatalError("The dequeued cell is not an instance of allTasksCellTableViewCell.")
        }
        
        let task = tasks[indexPath.row]
        
        if task.offeredUsers.count > 0 {
            cell.indicatorButton.isHidden = false
            cell.indicatorButton.setTitle("竞标", for: .normal)
        }
        //no need to check if tasks are assigned cause it is no need to show them
        
        cell.titleLabel.text = task.title
        cell.contentLabel.text = task.desc
        cell.budgetLabel.text = "$\(String(task.budget))"
        
        cell.profileImg.image = UIImage(named:"profilePhoto")
        
        
        if task.imageURL != "" {
            let imgUrl = URL(string: task.imageURL)
            cell.profileImg.kf.setImage(with: imgUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        
        let row = indexPath.row
        taskToBeTransferred = tasks[row]
        
        self.performSegue(withIdentifier: "toTaskDetail", sender: self)
        
        
    }
    
    @IBAction func backToAllTasks(segue:UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as? UINavigationController
        if segue.identifier == "toTaskDetail" {
            let destinationViewController = navVC?.viewControllers.first as! taskDetailViewController
            destinationViewController.task = taskToBeTransferred
            destinationViewController.user = self.user
            
        } else if segue.identifier == "allTasksToMap" {
            if let allTasksMapViewController = segue.destination as? allTasksMapViewController {
                allTasksMapViewController.user = self.user
            }
        }
        
        
    }
    
    func loadUser(){
        self.showLoadingHUD() //loading
        //assert user exists
        guard let id = Auth.auth().currentUser?.uid else {
            return showAlert(withTitle: "粗错了", message: "身份验证失败")
        }
        let userRef =  Database.database().reference().child("Users").child(id)
        
        //        userRef.observeSingleEvent(of: .value) { (snapshot) in
        //            // Get user value
        //            if let dictionary = snapshot.value as? [String:AnyObject] {
        //                self.user = Users(dictionary:dictionary)
        //            }
        //            self.loadFirTasks()
        //        }
        //
        
        userRef.observe(.value) { (snapshot) in
            // Get user value
            if let dictionary = snapshot.value as? [String:AnyObject] {
                self.user = Users(dictionary:dictionary)
            }
            self.loadFirTasks()
        }
        
    }
    
    func loadFirTasks() {
        
        //        if shouldLoadTask == false {
        //            return
        //        }
        //
        //        if shouldLoadTask == nil {
        //            shouldLoadTask = false
        //        }
        
        refTask = Database.database().reference().child("Tasks")
        refTask?.observe(.value, with: {(snapshot) in
            
            if snapshot.childrenCount > 0{
                self.tasks.removeAll()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
                
                for tasks in snapshot.children.allObjects as![DataSnapshot] {
                    if let dictionary = tasks.value as? [String:AnyObject] {
                        let task = Tasks(dictionary: dictionary)
                        
                        var bool = false
                        if let blockedUsers = self.user?.blockedUsers {
                            if  blockedUsers.contains(task.postedUser){
                                bool = true
                            }
                        }
                        
                        if task.assignedTasker == "" && task.dueDate >= Date() && !bool { //dont need "assigned" and due tasks
                            //                            self.tasks.append(task)
                            self.tasks.insert(task, at: 0)
                        }
                    }
                }
                self.tasksTemp = self.tasks // for temporarily replacing tasks in search config
                self.tableView.reloadData()
                self.addRedDotAtTabBarItemIndex(index: 2)//show red dot
                self.hideLoadingHUD()// hide loading indicator
            }
        })
        
    }
    
    //configuration
    
    func loacationManagerConfigure(){
        
        self.tableView.tableFooterView = UIView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
}

extension allTasksViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        myLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
