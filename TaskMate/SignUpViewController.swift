//
//  SignUpViewController.swift
//  TaskMate
//
//  Created by Wei Zheng on 27/7/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var refTask : DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createAccountAction(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alertController = UIAlertController(title: "出错了", message: "请先输入邮箱和密码", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    self.createUser()
                    //Goes to taskmate
                    self.performSegue(withIdentifier:"SignUpToTM", sender: nil)

                } else {
                    let alertController = UIAlertController(title: "出错了", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func createUser(){
        
        refTask = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            
            let sinceTime = Date()
            let newUser = Users(id: user.uid, displayName: user.email!, sinceTime: sinceTime, email: user.email!)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let time = formatter.string(from: newUser.sinceTime)
            
            let userToBeStored = [
                "id":newUser.id,
                "displayName": newUser.displayName,
                "sinceTime": time,
                "email":newUser.email
            ]
            
            refTask?.child("Users").child(newUser.id).setValue(userToBeStored)
            
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

}
