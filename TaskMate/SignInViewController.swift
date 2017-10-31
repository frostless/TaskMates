//
//  SignInViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 24/7/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import Alamofire


@objc(SignInViewController)

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    //@IBOutlet weak var GIDSignInButton: GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    var refTask : DatabaseReference?
    
    var selfView:UIView?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var wechatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if the disclaimer view should be shown
        if !UserDefaults.standard.bool(forKey: "isDisclaimerShown") {
            selfView = self.view
            let disclaimerView = DisclaimerView()
            self.view = disclaimerView
            disclaimerView.vc = self
            UserDefaults.standard.set(true, forKey: "isDisclaimerShown")
        }
      
        //register notification from app delegate
        NotificationCenter.default.addObserver(self, selector: #selector(wechatNotic(notice:)), name: NSNotification.Name(rawValue: "TaskNotice"), object: nil)
        //
        //check existence of wechat
        if !WXApi.isWXAppInstalled(){
            wechatButton.isHidden = true
        }
        //GGSignIn()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func GGSignIn() {
        // check Internet connectivity
        if (!self.isInternetAvailable()) {
            return self.showAlert(withTitle: "粗错了", message: "好像网络不给力哦")
        }
        
        self.showLoadingHUD()
        //GIDSignInButton.style = .iconOnly
        //GIDSignInButton.colorScheme = .dark
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        handle = Auth.auth().addStateDidChangeListener() {[weak self] (auth, user) in
            if user != nil {
                
                //should not perform the segue when user data has not been created in the database
//                self?.performSegue(withIdentifier:"SignInToTM", sender: nil)
                
                //MeasurementHelper.sendLoginEvent()
                self?.checkUserDuplicate(){[weak self] success in
                    if success {
                        self?.performSegue(withIdentifier:"SignInToTM", sender: nil)
                    } else {
                        self?.createUser()//create and upload user to db
                        self?.performSegue(withIdentifier:"SignInToTM", sender: nil)
                    }
                    self?.hideLoadingHUD()
                }
            }
        }
    }
    
    func checkUserDuplicate(completionHandler:@escaping (Bool) -> ())  {
        refTask = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        refTask?.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            completionHandler(snapshot.exists())
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkWeChatUserDuplicate(wechatId:String,completionHandler:@escaping (Bool) -> ())  {
        //
        //        let ref = Database.database().reference().child("Users").queryOrdered(byChild: "unionid").queryEqual(toValue: wechatId)
        //        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //             completionHandler(snapshot.exists())
        //    }) { (error) in
        //    print(error.localizedDescription)
        //        }
        let email = wechatId + "@taskmate.com"
        let password = wechatId
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code){
                    if errCode.rawValue == 17011 {
                        //user not existed,need to create one
                        completionHandler(false)
                    }else{
                        //other error
                        self.showAlert(withTitle: "粗错了...", message: error.localizedDescription)
                        print(error.localizedDescription)
                        self.hideLoadingHUD()
                    }
                }
                return
            }
            //no error
            completionHandler(true)
        }
        
    }
    
    func createUserWeChat(id:String,profileImage:String,name:String,email:String){
        refTask = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid
        let sinceTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
        let time = formatter.string(from: sinceTime )
        
        let userToBeStored = [
            "id":userId,
            "displayName": name,
            "sinceTime": time,
            "email":email,
            "unionid":id,
            "profilePhotoUrl": profileImage
        ]
        
        refTask?.child("Users").child(userId!).setValue(userToBeStored)
    }
    
    func createUser(){
        
        refTask = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user, let url = user.photoURL {
            
            let sinceTime = Date()
            
            let profilePhotoString = String(describing: url)
            let newUser = Users(id: user.uid, displayName: user.displayName!, sinceTime: sinceTime, email: user.email!,profilePhotoUrl: profilePhotoString)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let time = formatter.string(from: newUser.sinceTime)
            
            
            let userToBeStored = [
                "id":newUser.id,
                "displayName": newUser.displayName,
                "sinceTime": time,
                "email":newUser.email,
                "profilePhotoUrl": profilePhotoString
            ]
            
            refTask?.child("Users").child(newUser.id).setValue(userToBeStored)
        }
    }
    
    
    @objc func wechatNotic(notice:Notification) {
        guard let notice = notice.userInfo!["str"] else {
            return
        }
        
        Alamofire.request("https://api.weixin.qq.com/sns/oauth2/access_token?", method: HTTPMethod.get, parameters: ["appid":"wx1cad7813c27f5eb1" as Any,"secret":"a1416c0221405f2b1ef6a779b3019b47" as Any,"code":notice,"grant_type":"authorization_code"], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result {
            case .success(_):
                //把得到的JSON数据转为字典
                if let dic = response.result.value as? Dictionary<String, Any>{
                    guard let accessToken = dic["access_token"] as! String?,let wxOpenID = dic["openid"] as! String? else {
                        self.showAlert(withTitle: "粗错了", message: "微信回调不成功，请重新尝试")
                        self.hideLoadingHUD()
                        return
                    }
                    
                    self.setUserInfo(accessToken: accessToken, wxOpenID: wxOpenID)
                    
                }
            case .failure(_): break
                
            }
        }
        
    }
    
    func setUserInfo(accessToken:String,wxOpenID:String){
        Alamofire.request("https://api.weixin.qq.com/sns/userinfo?", method: HTTPMethod.get, parameters: ["access_token":accessToken as Any,"openid":wxOpenID as Any], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
                
            case .success(_):
                
                if let dic = response.result.value as? Dictionary<String, Any>{
                    
                    guard let unionid = dic["unionid"] as! String?, let nickname = dic["nickname"] as! String?, let headimgurl = dic["headimgurl"] as! String? else {
                        self.showAlert(withTitle: "粗错了", message: "微信用户信息获取不成功，请重新尝试")
                        self.hideLoadingHUD()
                        return
                    }
                    
                    self.checkWeChatUserDuplicate(wechatId:unionid){success in
                        
                        let email = unionid + "@taskmate.com"
                        let password = unionid
                        
                        if success {
                            self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                            self.hideLoadingHUD()
                            
                        } else {
                            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                if error == nil {
                                    self.createUserWeChat(id: unionid, profileImage: headimgurl, name: nickname, email: email)
                                    //Goes to taskmate
                                    self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                                } else {
                                    self.showAlert(withTitle: "粗错了", message: (error?.localizedDescription)!)
                                }
                            })
                            self.hideLoadingHUD()
                        }
                        
                    }
                }
            case .failure(_): break
            }
        }
    }
    
    
    @IBAction func wechatLogin(_ sender: Any) {
        // check Internet connectivity
        if (!self.isInternetAvailable()) {
            return self.showAlert(withTitle: "粗错了", message: "好像网络不给力哦")
        }
        
        self.showLoadingHUD()
        if !WXApi.isWXAppInstalled(){
            showAlert(withTitle: "粗错了", message: "没有在你的设备上检测到微信")
            self.hideLoadingHUD()
            return
        }
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "App"
        if !WXApi.send(req){
            showAlert(withTitle: "粗错了", message: "跟微信请求获取用户信息失败")
            self.hideLoadingHUD()
        }
        
    }
    
    
    @IBAction func facebookLogin(sender: UIButton) {
        // check Internet connectivity
        if (!self.isInternetAvailable()) {
            return self.showAlert(withTitle: "粗错了", message: "好像网络不给力哦")
        }
        
        self.showLoadingHUD()
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                self.showAlert(withTitle: "粗错了...", message: error.localizedDescription)
                print("Failed to login: \(error.localizedDescription)")
                self.hideLoadingHUD()
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                self.showAlert(withTitle: "粗错了...", message: "获取Facebook用户信息失败")
                print("Failed to get access token")
                self.hideLoadingHUD()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    self.showAlert(withTitle: "粗错了...", message: error.localizedDescription)
                    self.hideLoadingHUD()
                    return
                }
                self.hideLoadingHUD()
                // Perform the segue first
                self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                self.checkUserDuplicate(){success in
                    if success {
                        //self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                        print("you have successfully signed in")
                    } else {
                        self.createUser()//create and upload user to db
                        //self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                    }
                }
                
            })
            
        }
    }
    
    
    @IBAction func GoogleSignIn(_ sender: Any) {
        GGSignIn()
    }
    
    
    @IBAction func emailPasswordSignIn(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields
            
            self.showAlert(withTitle: "粗错了...", message: "请输入邮件和密码.")
            
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    self.performSegue(withIdentifier:"SignInToTM", sender: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    self.showAlert(withTitle: "粗错了...", message: (error?.localizedDescription)!)
                    
                }
            }
        }
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - for lingking back-up methods
    
    func signInUserWithEmail(email:String){
        
        let password = "123qwe12"
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user:User?, error:Error?) in
            
            if user != nil{
                
                self.linkAccountWihtFacebook()
                
            }else{
                
                //print(error?.localizedDescription)
            }
        })
        
    }
    
    func linkAccountWihtFacebook(){
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().currentUser?.link(with: credential, completion: { (user:User?, error:Error?) in
            
            if let LinkedUser = user{
                
                print("NEW USER:",LinkedUser.uid)
            }
            
            if (error as NSError?) != nil{
                
                //Indicates an attempt to link a provider of a type already linked to this account.
                //if error.code == AuthErrorCode.RawValue{
                print("FIRAuthErrorCode.errorCodeProviderAlreadyLinked")
            }
        })
    }
    
    
}
