//
//  SecondViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Parchment
import MaterialComponents.MaterialBottomAppBar

class ErrandPagingViewController: UIViewController {

    var pagingViewController: FixedPagingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storyboard = UIStoryboard(name: "Errand", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as! ErrandViewController
        let secondViewController = storyboard.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as! ErrandViewController
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        pagingViewController = FixedPagingViewController(viewControllers: [
            firstViewController,
            secondViewController
        ])
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutPagingView()
    }
    
    func layoutPagingView() {
        pagingViewController.view.autoPinEdge(toSuperviewEdge: .trailing)
        pagingViewController.view.autoPinEdge(toSuperviewEdge: .leading)
        if let naviBar = self.navigationController?.navigationBar {
            pagingViewController.view.autoPinEdge(.top, to: .bottom, of: naviBar)
        } else {
            pagingViewController.view.autoPinEdge(toSuperviewEdge: .top)
        }
        pagingViewController.view.autoPinEdge(toSuperviewEdge: .bottom)
        pagingViewController.didMove(toParentViewController: self)
    }

}

