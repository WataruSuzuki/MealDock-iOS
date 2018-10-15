//
//  SecondViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Parchment
import PureLayout
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer

class ErrandPagingViewController: UIViewController {

    let bottomBarView = MDCBottomAppBarView()
    var items: [MarketItems]!
    var pagingViewController: FixedPagingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = NSLocalizedString("errandFoods", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDone))

        let storyboard = UIStoryboard(name: "Errand", bundle: nil)
        var controllers = [ErrandViewController]()
        for i in 0..<Harvest.Section.max.rawValue{
            let controller = storyboard.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as! ErrandViewController
            controller.title = NSLocalizedString(items[i].type, comment: "")
            controller.items = items[i].items
            controllers.append(controller)
        }
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        pagingViewController = FixedPagingViewController(viewControllers: controllers)
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        
        instatiateBottomBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutPagingView()
        layoutBottomAppBar()
    }
    
    func layoutPagingView() {
        pagingViewController.view.autoPinEdge(toSuperviewEdge: .trailing)
        pagingViewController.view.autoPinEdge(toSuperviewEdge: .leading)
        if let naviBar = self.navigationController?.navigationBar {
            pagingViewController.view.autoPinEdge(.top, to: .bottom, of: naviBar)
        } else {
            pagingViewController.view.autoPinEdge(toSuperviewEdge: .top)
        }
        pagingViewController.view.autoPinEdge(.bottom, to: .top, of: bottomBarView, withOffset: bottomBarView.floatingButton.frame.height)
        //pagingViewController.view.autoPinEdge(toSuperviewEdge: .bottom)
        pagingViewController.didMove(toParentViewController: self)
    }

    func instatiateBottomBar() {
        view.addSubview(bottomBarView)
        
        bottomBarView.setFloatingButtonPosition(.trailing, animated: true)
        bottomBarView.floatingButton.setImage(UIImage(named: "baseline_mic_white_48pt"), for: .normal)
        bottomBarView.floatingButton.addTarget(self, action: #selector(tapMicToSpeech), for: .touchUpInside)
        bottomBarView.floatingButtonPosition = .center
        
        let barButtonLeadingItem = UIBarButtonItem(image: UIImage(named:"baseline_search_black_36pt")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tapSearch))
        let barButtonTrailingItem = UIBarButtonItem(image: UIImage(named:"baseline_photo_camera_black_36pt")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tapCamera))
        
        bottomBarView.leadingBarButtonItems = [ barButtonLeadingItem ]
        bottomBarView.trailingBarButtonItems = [ barButtonTrailingItem ]
    }
    
    private func layoutBottomAppBar() {
        let size = bottomBarView.sizeThatFits(view.bounds.size)
        let offset = (self.tabBarController != nil
            ? self.tabBarController!.tabBar.frame.height
            : 0)
        let bottomBarViewFrame = CGRect(
            x: 0,
            y: self.view.frame.height - (size.height + offset),
            width: size.width, height: size.height)
        bottomBarView.frame = bottomBarViewFrame
        
        bottomBarView.autoPinEdge(toSuperviewEdge: .trailing)
        bottomBarView.autoPinEdge(toSuperviewEdge: .leading)
        bottomBarView.autoSetDimension(.height, toSize: bottomBarView.frame.height)
        //bottomBarView.autoPinEdge(toSuperviewEdge: .bottom)
        bottomBarView.autoPinEdge(toSuperviewSafeArea: .bottom)
    }
    
    @objc func tapMicToSpeech() {
    }
    
    @objc func tapSearch() {
    }

    @objc func tapCamera() {
        performSegue(withIdentifier: String(describing: AddNewMarketItemViewController.self), sender: self)
    }
    
    @objc func tapDone() {
        let controllers = pagingViewController.viewControllers as! [ErrandViewController]
        for controller in controllers {
            debugPrint(controller.selectedItems)
            let items = [Harvest](controller.selectedItems.values)
            for item in items {
                FirebaseService.shared.addToErrand(harvest: item)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

