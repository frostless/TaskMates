
//
//  allMessagesViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 21/8/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase

class allMessagesViewController: UIViewController,UISearchBarDelegate {
    
    private var tableView: UITableView!
    private var headerView:UIView!
    private var searchBar: UISearchBar!
    var messages = [Messages]()
    var messagesTemp:[Messages]?
    var messagesDictionary = [String:Messages]()
    var user:Users?
    
    var shouldShowRedDot:Bool?
    var redDot:UIView?
    
    //    var timesToStopTableReload:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConfigue()
        UIconfigure()
        loadUser()
        keyboardConfigure()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        redDot?.removeFromSuperview()//disappear redDot
        shouldShowRedDot = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        shouldShowRedDot = true
    }
    
    deinit {
        
        if let id = Auth.auth().currentUser?.uid {
            Database.database().reference().child("Users").child(id).removeAllObservers()
        }
        
        
        if let messages = self.user?.messages {
            for ( _, msgID) in messages{
                let msgRef =  Database.database().reference().child("Messages").child(msgID)
                msgRef.removeAllObservers()
            }
        }
    }
    

    
    func addRedDotAtTabBarItemIndex(index:Int) {
        
        if shouldShowRedDot == false {
            return
        }
        
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
    
    
    //UI configure
    
    func tableViewConfigue(){
        
        headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        self.view.addSubview(headerView)
        
        //tableView,searchBar,headerView
        
        tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        self.view.addSubview(tableView)
        tableView.register(userCell.self, forCellReuseIdentifier: "cell")
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        
        headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10).isActive = true
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar = UISearchBar()
        
        headerView.addSubview(searchBar)
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.sizeToFit()
        searchBar.placeholder = "搜索"
        searchBar.setValue("取消", forKey:"_cancelButtonText")
        
        searchBar.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        searchBar.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        searchBar.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        
        
        
        
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        //        tableView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.83).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    
    func UIconfigure() {
        
        self.navigationItem.title = "全部消息"
    }
    
    
    func keyboardConfigure(){
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    
    //Loading
    
    func loadUser() {
        guard let id = Auth.auth().currentUser?.uid else {
            return showAlert(withTitle: "粗错了", message: "身份验证失败")
        }
        let userRef =  Database.database().reference().child("Users").child(id)
        
        showLoadingHUD()
        
        userRef.observe(.value, with: { (snapshot) in
            // Get user value
            if let dictionary = snapshot.value as? [String:AnyObject] {
                self.user = Users(dictionary: dictionary)
            }
            self.observeMessages()
        })
        
    }
    
    
    func observeMessages(){
        //clean the dic when user block user
        messagesDictionary = [:]
        //        guard let messages = self.user?.messages else {
        //            return
        //              self.hideLoadingHUD()
        //        }
        
        for ( _, msgID) in (self.user?.messages)!{
            
            let msgRef =  Database.database().reference().child("Messages").child(msgID)
            
            msgRef.observe(.value, with: {(snapshot) in
                
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    
                    guard let dictionary = snap.value as? [String:String] else {
                        return
                    }
                    let message = Messages(dictionary: dictionary)
                    //convert duplicate receiver && sender cell
                    
                    //                    let whichId = message.chatPartnerId()
                    //filter blocked users
                    var bool = false
                    if let blockedUsers = self.user?.blockedUsers {
                        if  blockedUsers.contains(message.chatPartnerId()){
                            bool = true
                        }
                    }
                    if !bool {
                        self.messagesDictionary[msgID] = message
                    }
                    
                }
                //only need to reload table once to make profileImg displayed correctly
                
                self.attemptReloadTable()
                self.addRedDotAtTabBarItemIndex(index: 3)//show red dot
                
            })
            
            msgRef.observe(.childRemoved, with: {(snapshot) in
                
                self.messagesDictionary.removeValue(forKey: msgID)
                self.attemptReloadTable()
            })
            //
        }
        self.hideLoadingHUD()
        
    }
    
    var timer:Timer?
    //    var counter = Int()
    
    func attemptReloadTable(){
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    
    @objc func handleReloadTable(){
        
        self.messages = Array(self.messagesDictionary.values)
        //                    self.messages.append(message)
        self.messages = self.messages.sorted(by: { $0.timeStamp.doubleValue > $1.timeStamp.doubleValue })
        messagesTemp = self.messages
        tableView.reloadData()
    }
    
    
    
    //MARK: searchbar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        searchBar.showsCancelButton = true
        if searchText.isEmpty || searchText == " "{
            if let messagesTemp = messagesTemp {
                messages = messagesTemp
                searchBar.showsCancelButton = false
            }
        }else{
            messages = messages.filter(
                { (t) -> Bool in
                    return t.content.contains(searchText)
            })
        }
        tableView.reloadData()
    }
    
    
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "allMsgToMsgDetails" {
            if let msgDetailsViewController = segue.destination as? msgDetailsViewController {
                msgDetailsViewController.msgReceiver = sender as? Users
                msgDetailsViewController.msgSender = user
                let backItem = UIBarButtonItem()
                backItem.title = "后退"
                navigationItem.backBarButtonItem = backItem
            }
            
        }
        
    }
    
}



extension allMessagesViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 1
        } else {
            
            return messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! userCell
        
        if messages.count == 0 {
            cell.textLabel?.text = "你还没有任何聊天信息"
            //delete cell element in case when user delete all existing messages
            cell.timeLabel.text = nil
            cell.profileImageView.image = nil
            cell.detailTextLabel?.text = nil
            
            
            
        } else {
            let message = messages[indexPath.row]
            cell.message = message
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if messages.count > 0 {
            
            let message = messages[indexPath.row]
            
            let chatPartnerId = message.chatPartnerId()
            let ref = Database.database().reference().child("Users").child(chatPartnerId)
            
            ref.observeSingleEvent(of:.value, with: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    let user = Users(dictionary: dictionary)
                    self.performSegue(withIdentifier: "allMsgToMsgDetails", sender: user)
                }
                
            })
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if messages.count > 0 {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        let chatPartnerId = message.chatPartnerId()
        
        let selfID = Auth.auth().currentUser?.uid
        let messageRef = user?.messages[chatPartnerId]
        
        Database.database().reference().child("Users").child(selfID!).child("messages").child(chatPartnerId).removeValue { (error, ref) in
            if let error = error {
                print("error:",error)
                return
            }
            Database.database().reference().child("Users").child(chatPartnerId).child("messages").child(selfID!).removeValue(completionBlock: { (error, ref) in
                if let error = error {
                    print("error:",error)
                    return
                }
                Database.database().reference().child("Messages").child(messageRef!).removeValue(completionBlock: { (error, ref) in
                    if let error = error {
                        print("error:",error)
                        return
                    }
                    //                        self.counter -= 1
                    self.messagesDictionary.removeValue(forKey: messageRef!)
                    self.attemptReloadTable()
                })
            })
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}
