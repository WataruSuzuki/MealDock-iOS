//
//  DishListViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialCards_CardThemer
import MaterialComponents.MaterialColorScheme
import MaterialComponents.MaterialTypographyScheme

private let reuseIdentifier = "DishCollectionCell"

class DishListViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    var colorScheme = MDCSemanticColorScheme()
    var shapeScheme = MDCShapeScheme()
    var typographyScheme = MDCTypographyScheme()
    let cardScheme = MDCCardScheme()
    let fab = MDCFloatingButton()
    
    var checkedItems = [String : Dish]()
    var dishes = [Dish]()
    
    var checkBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    var isSelectMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(fab)
        fab.isHidden = true
        activateFab(fab: fab, target: self, image: UIImage(named: "baseline_local_dining_black_36pt")!, selector: #selector(onFabTapped))
        
        self.title = NSLocalizedString("dishes", comment: "")
        self.collectionView!.register(DishCardCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        
        checkBarButton = UIBarButtonItem(image: UIImage(named: "baseline_check_box_black_36pt")!, style: .plain, target: self, action: #selector(changeSelectingMode))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(changeSelectingMode))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        FirebaseService.shared.observeDishes { (dishes) in
            self.dishes = dishes
            if dishes.count > 0 {
                self.navigationItem.rightBarButtonItem = (self.isSelectMode ? self.cancelBarButton : self.checkBarButton)
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.collectionView!.reloadData()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.layout(fab: self.fab)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cardCell = cell as? DishCardCollectionCell else { return cell }

        cardCell.apply(cardScheme: cardScheme, typographyScheme: typographyScheme)
        // Configure the cell
        cardCell.configure(title: dishes[indexPath.row].title, imageName: "baseline_help_black_48pt")
        GooglePhotosService.shared.getMediaItemUrl(MEDIA_ITEM_ID: dishes[indexPath.row].imagePath) { (url, error) in
            guard error == nil else { return }
            cardCell.imageView.setImageByAlamofire(with: URL(string: url)!)
        }
        cardCell.selectingMode = isSelectMode
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardSize = (collectionView.bounds.size.width / 2) - 12
        return CGSize(width: cardSize, height: cardSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DishCardCollectionCell
        let dish = dishes[indexPath.row]
        if isSelectMode {
            cell.isChecked = !cell.isChecked
            if cell.isChecked {
                checkedItems.updateValue(dish, forKey: dish.title)
            } else {
                checkedItems.removeValue(forKey: dish.title)
            }
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Foods")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Let's start to add foods")
    }
    
    @objc func changeSelectingMode() {
        fab.isHidden = isSelectMode
        isSelectMode = !isSelectMode
        self.collectionView?.reloadData()
        if !isSelectMode {
            checkedItems.removeAll()
            self.navigationItem.rightBarButtonItem = checkBarButton
        } else {
            self.navigationItem.rightBarButtonItem = cancelBarButton
        }
    }
    
    @objc func onFabTapped() {
        let items = [Dish](checkedItems.values)
        if items.count > 0 {
            FirebaseService.shared.removeDishes(dishes: items)
            UIViewController.snackBarMessage(text: "(=^ ω ^=)" + NSLocalizedString("gochi_sou_sama", comment: ""))
        } else {
            UIViewController.snackBarMessage(text: "(=・∀・=)??")
        }
    }
}
