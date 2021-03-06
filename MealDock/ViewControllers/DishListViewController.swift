//
//  DishListViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/16.
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
    var typographyScheme = MDCTypographyScheme()
    let cardScheme = MDCCardScheme()
    let fab = MDCFloatingButton()
    
    var checkedItems = [String : Dish]()
    var dishes = [Dish]()
    let refreshControl = UIRefreshControl()
    
    var checkBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    var isSelectMode = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        PurchaseService.shared.load(unitId: "YOUR_AD_UNIT_ID_FOR_NATIVE", controller: self)

        view.addSubview(fab)
        fab.isHidden = true
        activateFab(fab: fab, target: self, image: UIImage(named: "baseline_local_dining_black_36pt")!, tap: #selector(onFabTapped), longTap: nil)
        
        self.title = "dishes".localized
        self.collectionView!.register(DishCardCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        
        checkBarButton = UIBarButtonItem(title: "select".localized, style: .plain, target: self, action: #selector(changeSelectingMode))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(changeSelectingMode))
        
        if #available(iOS 10.0, *) {
            self.collectionView!.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        FirebaseService.shared.observeDishes { (dishes) in
            self.updateDishList(newDishes: dishes)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.layout(fab: self.fab)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionView?.setNeedsLayout()
        }, completion: nil)
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
        let dish = dishes[indexPath.row]
        if let image = ImageCacheService.shared.imageCache.image(withIdentifier: dish.imagePath) {
            cardCell.configure(title: dish.title, image: image)
        } else {
            cardCell.configure(title: dish.title, image: UIImage(named: "empty_white")!)
            let indicator = cardCell.startIndicator()
            GooglePhotosService.shared.getMediaItemUrl(MEDIA_ITEM_ID: dish.imagePath) { (url, error) in
                cardCell.stopIndicator(view: indicator)
                if let error = error {
                    print(error)
                    cardCell.imageView.image = UIImage(named: "baseline_help_black_48pt")!.withRenderingMode(.alwaysOriginal)
                } else {
                    cardCell.imageView.setImageByAlamofire(with: URL(string: url)!, cacheKey: dish.imagePath)
                }
            }
        }
        if dish.title == "💩" {
            if let nativeView = PurchaseService.shared.nativeView() {
                nativeView.frame = cardCell.frame
                cardCell.addSubview(nativeView)
                nativeView.autoPinEdgesToSuperviewEdges()
                if !PurchaseService.shared.applyNativeAd(view: nativeView) {
                    debugPrint("Ad is not applied now")
                }
            }
            cardCell.selectingMode = false
        } else {
            cardCell.selectingMode = isSelectMode
        }
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.getCellSize(baseCellNum: 2)
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
        if cell.selectingMode {
            cell.isChecked = !cell.isChecked
            if cell.isChecked {
                checkedItems.updateValue(dish, forKey: dish.title)
            } else {
                checkedItems.removeValue(forKey: dish.title)
            }
        } else {
            performSegue(withIdentifier: String(describing: DetailDishViewController.self), sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case String(describing: DetailDishViewController.self):
                if let detail = segue.destination as? DetailDishViewController,
                    let indexPaths = self.collectionView?.indexPathsForSelectedItems {
                    detail.dish = dishes[indexPaths[0].row]
                    if let cell = self.collectionView?.cellForItem(at: indexPaths[0]) as? DishCardCollectionCell {
                        detail.loadedImage = cell.imageView.image
                    }
                }
            default:
                break
            }
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "no_dishes".localized)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "msg_add_dishes".localized)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        if let _ =  FirebaseService.shared.currentUser {
            return NSAttributedString()
        } else {
            return NSAttributedString(string: "signIn".localized)
        }
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard FirebaseService.shared.currentUser == nil else { return }
        FirebaseService.shared.requestAuthUI()
    }
    
    private func updateDishList(newDishes: [Dish]) {
        dishes = newDishes
        if dishes.count > 0 {
            self.navigationItem.rightBarButtonItem = (isSelectMode ? cancelBarButton : checkBarButton)
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        self.collectionView!.reloadData()
    }
    
    @objc private func refresh() {
        FirebaseService.shared.loadDishes(success: { (dishes) in
            self.updateDishList(newDishes: dishes)
            self.refreshControl.endRefreshing()
        })
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
            UIViewController.snackBarMessage(text: "(=^ ω ^=)" + "gochi_sou_sama".localized)
            checkedItems.removeAll()
            isSelectMode = false
            fab.isHidden = true
            self.collectionView?.reloadData()
        } else {
            UIViewController.snackBarMessage(text: "(=・∀・=)??")
        }
    }
}
