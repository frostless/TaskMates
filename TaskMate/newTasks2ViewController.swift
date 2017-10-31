//  newTasks2ViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 5/26/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit
import Firebase

class newTasks2ViewController: UIViewController,UITextFieldDelegate {
    
    var refTask : DatabaseReference?
    var task: Tasks?
    var imageURL:String?
    var stepValue0: Double?
    var stepValue1: Double?
    

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var counter: UILabel!
    
    @IBOutlet weak var taskBudgetLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var hourlyTextField: UITextField!
    @IBOutlet weak var hourlyRateTextField: UITextField!
    
    @IBOutlet weak var isHourlyRate: UISegmentedControl!
    
    @IBOutlet weak var estimatedBudget: UILabel!
    
    @IBOutlet weak var hourlyEstimatedBudget: UILabel!
    
    @IBAction func confirm(_ sender: Any) {
        
        if isHourlyRate.selectedSegmentIndex == 0 && (budgetTextField.text?.characters.count)! > 1  {
            task?.taskerNumber = Int(self.stepper.value)
            if let str = budgetTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
                let budget = str[startIndex...]
                task?.budget = Int(budget)!
                proceedToNext0()
            }
        } else if isHourlyRate.selectedSegmentIndex == 1 && (hourlyTextField.text?.characters.count)!  > 0 && (hourlyRateTextField.text?.characters.count)! > 1  {
            if let str = hourlyRateTextField.text,let hour = hourlyTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
                let hourlyBudget = Int(str[startIndex...])!
                let hours = Int(hour)!
                task?.hours = hours
                task?.budget = hourlyBudget*hours
                proceedToNext1()
            }
        } else {
            showAlert(withTitle: "出错了。。", message: "必须设定任务预算")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refTask = Database.database().reference()
        configureUI()
        fetchProfileImageURL()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.length>0  && range.location == 0 && textField.text == "$" {
            return false
        }
        //restrict input number length
        
        var startString = ""
        if (textField.text != nil)

        {
            startString += textField.text!
        }
        startString += string
        let limitNumber = startString.characters.count
        
        if textField == hourlyTextField && limitNumber > 3{
        return false
        } else if textField == budgetTextField && limitNumber > 6 {
            return false
        } else if textField == hourlyRateTextField && limitNumber > 4 {
            return false
        } else {
            return true
        }
    }
    
    @objc func budgetTextFieldDidChange(_ sender:AnyObject) {
        if isHourlyRate.selectedSegmentIndex == 0 && (budgetTextField.text?.characters.count)! > 1 {
            
            if let str = budgetTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
                let budget = Int(str[startIndex...])!
                if Int(stepper.value) == 1 {
                    estimatedBudget.text = "任务预计费用为\(budget)澳币"
                } else {
                    estimatedBudget.text = "任务预计费用为每人\(budget/Int(stepper.value))澳币"
                }
            }
        } else {
            estimatedBudget.text = ""
        }
    }
    
    @objc func hourlyRateTextFieldDidChange(_ sender:AnyObject) {
        if (hourlyTextField.text?.characters.count)! > 0 && (hourlyRateTextField.text?.characters.count)! > 1 && isHourlyRate.selectedSegmentIndex == 1 {
            
            if let str = hourlyRateTextField.text,let hour = hourlyTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
               let hourlyBudget = Int(str[startIndex...])!
                let hours = Int(hour)!
                if Int(stepper.value) == 1 {
                    hourlyEstimatedBudget.text = "任务预计费用为\(hourlyBudget*hours)澳币"
                } else {
                    hourlyEstimatedBudget.text = "任务预计费用为每人\(hourlyBudget*hours/Int(stepper.value))澳币"
                }
            }
        } else {
            hourlyEstimatedBudget.text = ""
        }
    }
    
    @objc func hourlyTextFieldDidChange(_ sender:AnyObject) {
        if (hourlyTextField.text?.characters.count)! > 0 && (hourlyRateTextField.text?.characters.count)! > 1 && isHourlyRate.selectedSegmentIndex == 1 {
            
            if let str = hourlyRateTextField.text,let hour = hourlyTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
               let hourlyBudget = Int(str[startIndex...])!
                let hours = Int(hour)!
                if Int(stepper.value) == 1 {
                    hourlyEstimatedBudget.text = "任务预计费用为\(hourlyBudget*hours)澳币"
                } else {
                    hourlyEstimatedBudget.text = "任务预计费用为每人\(hourlyBudget*hours/Int(stepper.value))澳币"
                }
            }
        } else {
            hourlyEstimatedBudget.text = ""
        }
    }
    
    
    @objc func paymentModeChanged(segment: UISegmentedControl){
        if segment.selectedSegmentIndex == 0 {
            hourlyRateLabel.isHidden = true
            hourlyTextField.isHidden = true
            hourlyRateTextField.isHidden = true
            budgetTextField.isHidden = false
            taskBudgetLabel.text = "任务预算是？"
            task?.ishourlyRate = false
            hourlyEstimatedBudget.isHidden = true
            estimatedBudget.isHidden = false
            
            stepValue1 = stepper.value
            if let value = stepValue0 {
                stepper.value = value
                counter.text = "\(Int(value))"
            }
        } else {
            hourlyRateLabel.isHidden = false
            hourlyTextField.isHidden = false
            hourlyRateTextField.isHidden = false
            budgetTextField.isHidden = true
            taskBudgetLabel.text = "需要小时数？"
            task?.ishourlyRate = true
            estimatedBudget.isHidden = true
            hourlyEstimatedBudget.isHidden = false
            
            stepValue0 = stepper.value
            if let value = stepValue1 {
                stepper.value = value
                counter.text = "\(Int(value))"
            } else {
                stepper.value = 1.0
                counter.text = "1"
            }
        }
    }
    
    @objc func update() {
        counter.text =  "\(Int(stepper.value))"
        task?.taskerNumber = Int(counter.text!)!
        
        if isHourlyRate.selectedSegmentIndex == 0 && (budgetTextField.text?.characters.count)! > 1 {
            
            if let str = budgetTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
                let budget = Int(str[startIndex...])!
                if Int(stepper.value) == 1 {
                    estimatedBudget.text = "任务预计费用为\(budget)澳币"
                } else {
                    estimatedBudget.text = "任务预计费用为每人\(budget/Int(stepper.value))澳币"
                }
            }
        } else  if (hourlyTextField.text?.characters.count)! > 0 && (hourlyRateTextField.text?.characters.count)! > 1 && isHourlyRate.selectedSegmentIndex == 1 {
            
            if let str = hourlyRateTextField.text,let hour = hourlyTextField.text {
                let startIndex = str.index(str.startIndex, offsetBy: 1)
               let hourlyBudget = Int(str[startIndex...])!
                let hours = Int(hour)!
                if Int(stepper.value) == 1 {
                    hourlyEstimatedBudget.text = "任务预计费用为\(hourlyBudget*hours)澳币"
                } else {
                    hourlyEstimatedBudget.text = "任务预计费用为每人\(hourlyBudget*hours/Int(stepper.value))澳币"
                }
            }
        } else if isHourlyRate.selectedSegmentIndex == 0 && (budgetTextField.text?.characters.count)! < 1 {
            estimatedBudget.text = ""
        } else if (hourlyTextField.text?.characters.count)! <= 0 && (hourlyRateTextField.text?.characters.count)! < 1 && isHourlyRate.selectedSegmentIndex == 1{
            hourlyEstimatedBudget.text = ""
        }
        
        
    }
    
    func proceedToNext0() {
        
        let startIndex = budgetTextField.text!.index(budgetTextField.text!.startIndex, offsetBy: 1)
        if Int(budgetTextField.text![startIndex...])!>=5 {
            
            if self.imageURL == nil {
                self.imageURL = ""
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let dueDateString = formatter.string(from: (self.task?.dueDate)!)
            let createdDateString = formatter.string(from: (self.task?.createdDate)!)
            
            let key = refTask?.childByAutoId().key
            
            let taskToBeStored = [
                "id":key,
                "title":self.task?.title,
                "desc":self.task?.desc,
                "dueDate":dueDateString,
                "createdDate":createdDateString,
                "latitude":String(describing: (self.task?.latitude)!),
                "longitude":String(describing: (self.task?.longitude)!),
                "location":self.task?.location,
                "budget":String(describing: (self.task?.budget)!),
                "hourlyRate":String(describing: (self.task?.hourlyRate)!),
                "hours":String(describing: (self.task?.hours)!),
                "taskerNumber":String(describing: (self.task?.taskerNumber)!),
                "isOnline":String(describing: (self.task?.isOnline)!),
                "ishourlyRate":String(describing: (self.task?.ishourlyRate)!),
                "postedUser":Auth.auth().currentUser?.uid,
                "imageURL":self.imageURL
            ]
            
            refTask?.child("Tasks").child(key!).setValue(taskToBeStored)
            
            //update user
            let refUser = Database.database().reference().child("Users")
            refUser.child((Auth.auth().currentUser?.uid)!).child("postedTasks").child(key!).setValue(true)
            
            
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            // let allTasksvc = mainStoryboard.instantiateViewController(withIdentifier: "allTasksVC") as! allTasksViewController
            // allTasksvc.task = task
            
            let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            //let nvc = vc.viewControllers?[1] as! UINavigationController
            //let destinationVC = nvc.viewControllers[0] as! myTasksTableViewController
            //destinationVC.task = task
            vc.selectedIndex = 1
            self.present(vc, animated: true, completion: nil)
        } else {
            showAlert(withTitle: "出错了..", message: "预算不能小于5澳币.")
        }
    }
    
    func proceedToNext1() {
        
        
        let startIndex = hourlyRateTextField.text!.index(hourlyRateTextField.text!.startIndex, offsetBy: 1)
       if Int(hourlyRateTextField.text![startIndex...])! * Int(hourlyTextField.text!)! >= 5 {
            
            if self.imageURL == nil {
                self.imageURL = ""
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm:ssZZZZZ"
            let dueDateString = formatter.string(from: (self.task?.dueDate)!)
            let createdDateString = formatter.string(from: (self.task?.createdDate)!)
            
            let key = refTask?.childByAutoId().key
            
            let taskToBeStored = [
                "id":key,
                "title":self.task?.title,
                "desc":self.task?.desc,
                "dueDate":dueDateString,
                "createdDate":createdDateString,
                "latitude":String(describing: (self.task?.latitude)!),
                "longitude":String(describing: (self.task?.longitude)!),
                "location":self.task?.location,
                "budget":String(describing: (self.task?.budget)!),
                "hourlyRate":String(describing: (self.task?.hourlyRate)!),
                "hours":String(describing: (self.task?.hours)!),
                "taskerNumber":String(describing: (self.task?.taskerNumber)!),
                "isOnline":String(describing: (self.task?.isOnline)!),
                "ishourlyRate":String(describing: (self.task?.ishourlyRate)!),
                "postedUser":Auth.auth().currentUser?.uid,
                "imageURL":self.imageURL
            ]
            
            refTask?.child("Tasks").child(key!).setValue(taskToBeStored)
            
            //update user
            let refUser = Database.database().reference().child("Users")
            refUser.child((Auth.auth().currentUser?.uid)!).child("postedTasks").child(key!).setValue(true)
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            //let allTasksvc = mainStoryboard.instantiateViewController(withIdentifier: "allTasksVC") as! allTasksViewController
            // allTasksvc.task = task
            
            let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            //let nvc = vc.viewControllers?[1] as! UINavigationController
            // let destinationVC = nvc.viewControllers[0] as! myTasksTableViewController
            // destinationVC.task = task
            vc.selectedIndex = 1
            self.present(vc, animated: true, completion: nil)
        } else {
            showAlert(withTitle: "出错了..", message: "预算不能小于5澳币.")
        }
    }

    func fetchProfileImageURL() {
        let refUser =  Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!)
        
        refUser.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let url = value?["profilePhotoUrl"]{
                self.imageURL = url as? String
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func configureUI() {
        
        stepper.value = 1
        stepper.minimumValue = 1
        stepper.maximumValue = 10
        stepper.stepValue = 1
        
        stepper.addTarget(self, action: #selector(update), for: .valueChanged)
        
        
        hourlyRateLabel.isHidden = true
        hourlyTextField.isHidden = true
        hourlyRateTextField.isHidden = true
        
        hourlyTextField.delegate = self
        
        isHourlyRate.addTarget(self, action: #selector(paymentModeChanged), for: .valueChanged)
        // Do any additional setup after loading the view.
        
        //configue textFiled
        budgetTextField.text = "$"
        hourlyRateTextField.text = "$"
        budgetTextField.delegate = self
        hourlyRateTextField.delegate = self
        budgetTextField.addTarget(self, action: #selector(budgetTextFieldDidChange(_:)), for: .editingChanged)
        hourlyRateTextField.addTarget(self, action: #selector(hourlyRateTextFieldDidChange(_:)), for: .editingChanged)
        hourlyTextField.addTarget(self, action: #selector(hourlyTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if (task?.ishourlyRate == false && hourlyTextField.text != "" && hourlyRateTextField.text != ""){
     task?.hours = hourlyTextField.text!
     task?.hourlyRate = hourlyRateTextField.text!
     } else if (task?.ishourlyRate == true && budgetTextField.text != ""  ){
     task?.budget = budgetTextField.text!
     }
     
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     /*
     if let destinationViewController = segue.destination as? myTasksTableViewController {
     destinationViewController.task = task
     }
     */
     
     let navVC = segue.destination as? UINavigationController
     
     let destinationViewController = navVC?.viewControllers.first as! myTasksTableViewController
     
     destinationViewController.task = task
     }
     
     */
}
