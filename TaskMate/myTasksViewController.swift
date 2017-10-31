//
//  myTasksViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 24/7/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import Firebase
import Kingfisher

class myTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    //MARK: Properties
    let locationManager = CLLocationManager()
    var myLocation = CLLocation()
    var refTask : DatabaseReference?
    //var task: Tasks?
    var tasks = [Tasks]()
    var tasksTemp = [Tasks]()
    var taskToBeTransferred: Tasks?
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfTasksExit(){success in
            if success {
                self.loadFirTasks()
            } else {
                self.hideLoadingHUD()// hide loading indicator
                self.showAlert(withTitle: "嗯..", message: "看起来您还没有发布任何任务哦")
            }
        }
        
        self.tableView.tableFooterView = UIView()
        locationManagerConfigue()
        
    }
    
    deinit {
        Database.database().reference().child("Tasks").queryOrdered(byChild: "postedUser").queryEqual(toValue: Auth.auth().currentUser?.uid).removeAllObservers()
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "myTasksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? allTasksCellTableViewCell  else {
            fatalError("The dequeued cell is not an instance of myTasksTableViewCell.")
        }
        
        let task = tasks[indexPath.row]
        
        if task.offeredUsers.count > 0 {
            cell.indicatorButton.isHidden = false
            cell.indicatorButton.setTitle("竞标", for: .normal)
        }
        
        if task.assignedTasker != "" {
            cell.indicatorButton.isHidden = false
            cell.indicatorButton.setTitle("中标", for: .normal)
        }
        
        if task.dueDate < Date() {
            cell.indicatorButton.isHidden = false
            cell.indicatorButton.setTitle("过期", for: .normal)
        }
        
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
        self.performSegue(withIdentifier: "taskDetails", sender: self)
    }
    
    func checkIfTasksExit(completionHandler:@escaping (Bool) -> ())  {
        self.showLoadingHUD() //loading
        
        guard let id = Auth.auth().currentUser?.uid else {
            self.hideLoadingHUD()// hide loading indicator
            return showAlert(withTitle: "粗错了", message: "身份验证失败")
        }
        
        let refUsers = Database.database().reference().child("Users").child(id).child("postedTasks")
        
        refUsers.observeSingleEvent(of: .value, with: { (snapshot) in
            
            completionHandler(snapshot.exists())
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    private func loadFirTasks() {
        
        //refTask = Database.database().reference().child("Tasks")
        //self.showLoadingHUD() //loading
        guard let id = Auth.auth().currentUser?.uid else {
            return showAlert(withTitle: "粗错了", message: "身份验证失败")
        }
        
        let ref  = Database.database().reference().child("Tasks").queryOrdered(byChild: "postedUser").queryEqual(toValue:id)
        
        ref.observe(DataEventType.value, with: {(snapshot) in
            
            if snapshot.exists() {
                self.tasks.removeAll()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
                
                for task in snapshot.children.allObjects as![DataSnapshot] {
                    if let dictionary = task.value as? [String:AnyObject] {
                        let task = Tasks(dictionary: dictionary)
//                        self.tasks.append(task)
                        self.tasks.insert(task, at: 0)
                    }
                }
                self.tasksTemp = self.tasks // for temporarily replacing tasks in search config
                self.tableView.reloadData()
                self.hideLoadingHUD()// hide loading indicator
            }
        })
    }
    
 
    
    
    func locationManagerConfigue(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    // MARK: - Navigation
    
    @IBAction func backToMyTasks(segue:UIStoryboardSegue) {
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVC = segue.destination as? UINavigationController
        
        let destinationViewController = navVC?.viewControllers.first as! myNewTaskViewController
        
        destinationViewController.task = taskToBeTransferred
        
    }
}
extension myTasksViewController : CLLocationManagerDelegate {
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
