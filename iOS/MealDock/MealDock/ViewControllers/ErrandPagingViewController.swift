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

    var items: [MarketItems]!
    var pagingViewController: FixedPagingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDismiss))
        
        let storyboard = UIStoryboard(name: "Errand", bundle: nil)
        var viewControllers = [ErrandViewController]()
        for i in 0..<Harvest.Section.max.rawValue{
            let controller = storyboard.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as! ErrandViewController
            controller.title = NSLocalizedString(items[i].type, comment: "")
            controller.items = items[i].items
            viewControllers.append(controller)
        }
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        pagingViewController = FixedPagingViewController(viewControllers: viewControllers)
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

