//
//  MealDockBaseCollectionViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer
import PureLayout

protocol MealDockAdder {
    func onAddFabTapped()
}

class MealDockBaseCollectionViewController: MDCCollectionViewController,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    let reuseIdentifier = "MDCCollectionViewTextCell"
    let fab = MDCFloatingButton()
    
    var emptyMessage: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        
//        emptyMessage = createEmptyView()
//        emptyMessage.isHidden = true
        instantiateFab()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            //self.layoutBottomAppBar()
        }
        fab.autoPinEdge(.bottom, to: .top, of: (self.tabBarController?.tabBar)!, withOffset: -30)
        fab.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of items
//        return 0
//    }

//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//    
//        // Configure the cell
//    
//        return cell
//    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Foods")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Let's start to add foods")
    }
    
//    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
//        return emptyMessage
//    }
    
//    fileprivate func createEmptyView() -> UIView {
//        let card = MDCCard(frame: self.view.bounds)
//
//        let label = UILabel()
//        label.text = "No foods"
//        card.addSubview(label)
//        label.autoCenterInSuperview(in: card)
//
//        self.view.addSubview(card)
//        card.edges(to: self.view, insets: UIEdgeInsets(top: (self.navigationController?.navigationBar.frame.height)! * 2, left: 16, bottom: -((self.tabBarController?.tabBar.frame.height)! * 2), right: -16))
//
//        return card
//    }
    
    func updateEmptyMessage(section: Int) {
        if section == 0 {
            //self.view.addSubview(emptyMessage)
            //emptyMessage.isHidden = false
        } else {
            //emptyMessage.removeFromSuperview()
            //emptyMessage.isHidden = true
        }
    }
    
    func instantiateFab() {
        fab.setImage(UIImage(named: "baseline_add_black_24pt"), for: .normal)
        addTargetToFab(target: self, action: #selector(onAddFabTapped))
        view.addSubview(fab)
    }
    
    func addTargetToFab(target: Any?, action: Selector) {
        fab.addTarget(target, action: action, for: .touchUpInside)
    }
    
    @objc func onAddFabTapped() {
        
    }
    
    @objc func onMenuButtonTapped() {
    }
    
    func onSearchButtonTapped() {
    }
}
