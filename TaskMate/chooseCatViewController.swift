//
//  chooseCatViewController.swift
//  TaskMate
//
//  Created by Zheng Wei on 5/20/17.
//  Copyright © 2017 Zheng Wei. All rights reserved.
//

import UIKit

class chooseCatViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVC = segue.destination as? UINavigationController
        
        let destinationViewController = navVC?.viewControllers.first as! newTasksViewController
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
//        case "others":destinationViewController.taskType = "others"
        case "cleaning": destinationViewController.taskType = "cleaning"
        case "travelling": destinationViewController.taskType = "travelling"
        case "moving": destinationViewController.taskType = "moving"
        case "it":  destinationViewController.taskType = "it"
        case "buyingAgent": destinationViewController.taskType = "buyingAgent"
        case "renting": destinationViewController.taskType = "renting"
        default:showAlert(withTitle: "粗错了", message: "任务类型选择错误")
        }
        
    }
 
    
   
    @IBAction func backToTasksViewController(segue:UIStoryboardSegue) {
    }
}
