//
//  MealDockBaseCollectionViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

class MealDockBaseCollectionViewController: MDCCollectionViewController,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    let reuseIdentifier = "MDCCollectionViewTextCell"
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
        
        emptyMessage = getEmptyView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return getEmptyView()
    }
    
    fileprivate func getEmptyView() -> UIView {
        let card = MDCCard(frame: self.view.bounds)
        
        let flatButton = MDCFlatButton()
        flatButton.setTitleColor(.blue, for: .normal)
        flatButton.setTitle("Flat Button", for: .normal)
        flatButton.sizeToFit()
        card.addSubview(flatButton)
        flatButton.center(in: card)
        
        let label = UILabel()
        label.text = "No foods"
        card.addSubview(label)
        label.centerX(to: card)
        label.bottomToTop(of: flatButton)
        
        self.view.addSubview(card)
        card.edges(to: self.view, insets: UIEdgeInsets(top: (self.navigationController?.navigationBar.frame.height)!, left: 16, bottom: -((self.tabBarController?.tabBar.frame.height)!), right: -16))

        return card
    }
    
    func updateEmptyMessage(section: Int) {
        if section == 0 {
            self.view.addSubview(emptyMessage)
        } else {
            emptyMessage.removeFromSuperview()
        }
    }
}
