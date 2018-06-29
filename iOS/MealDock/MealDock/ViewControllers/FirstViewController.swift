//
//  FirstViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirebaseService.shared.addUser()
    }
    
}

