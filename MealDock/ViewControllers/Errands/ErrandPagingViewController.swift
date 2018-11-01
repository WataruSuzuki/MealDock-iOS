//
//  SecondViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Parchment
import PureLayout
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer

class ErrandPagingViewController: UIViewController,
    SearchMarketItemViewDelegate,
    UpdateCustomMarketItemDelegate
{

    let bottomBarView = MDCBottomAppBarView()
    var items: [MarketItems]!
    var pagingViewController: FixedPagingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = NSLocalizedString("errandFoods", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDone))
        
        instatiatePavingViews()
        instatiateBottomBar()
    }

    func instatiatePavingViews() {
        let storyboard = UIStoryboard(name: "Errand", bundle: nil)
        var controllers = [ErrandViewController]()
        for i in (0..<items.count).reversed() {
            let controller = storyboard.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as! ErrandViewController
            controller.items = items[i].items
            if let section = Harvest.Section(rawValue: i) {
                controller.title = section.emoji()
            }
            controllers.append(controller)
        }
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        pagingViewController = FixedPagingViewController(viewControllers: controllers)
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
    }
    
    func removePagingViews() {
        pagingViewController.view.removeFromSuperview()
        pagingViewController.removeFromParentViewController()
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
        pagingViewController.view.autoPinEdge(.bottom, to: .top, of: bottomBarView, withOffset: bottomBarView.floatingButton.frame.height - 20)
        //pagingViewController.view.autoPinEdge(toSuperviewEdge: .bottom)
        pagingViewController.didMove(toParentViewController: self)
    }

    func instatiateBottomBar() {
        view.addSubview(bottomBarView)
        
        bottomBarView.setFloatingButtonPosition(.trailing, animated: true)
        bottomBarView.floatingButton.setImage(UIImage(named: "baseline_search_black_36pt"), for: .normal)
        bottomBarView.floatingButton.addTarget(self, action: #selector(tapSearch), for: .touchUpInside)
        bottomBarView.floatingButtonPosition = .center
        //bottomBarView.setFloatingButtonHidden(true, animated: true)
        
        let barButtonLeadingItem = UIBarButtonItem(image: UIImage(named:"baseline_more_horiz_black_36pt")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tapMore))
        let barButtonTrailingItem = UIBarButtonItem(title: NSLocalizedString("addNewMarketItem", comment: ""), style: .plain, target: self, action: #selector(tapCamera))
            //UIBarButtonItem(image: UIImage(named:"baseline_photo_camera_black_36pt")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tapCamera))
        
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
    
    func updatedItem() {
        FirebaseService.shared.loadMarketItems(success: { (items) in
            self.items = items
            DispatchQueue.main.async {
                self.removePagingViews()
                self.instatiatePavingViews()
                self.dismiss(animated: true, completion: nil)
            }
        }) { (error) in
            OptionalError.alertErrorMessage(error: error)
        }
    }
    
    func didSelect(harvest: Harvest, indexPath: IndexPath) {
        let controllers = pagingViewController.viewControllers as! [ErrandViewController]
        controllers[indexPath.section].selectedItems.updateValue(harvest, forKey: harvest.name)
        controllers[indexPath.section].collectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapSearch() {
        let sb = UIStoryboard(name: "Errand", bundle: Bundle.main)
        if let viewController = sb.instantiateViewController(withIdentifier: String(describing: SearchMarketItemViewController.self)) as? SearchMarketItemViewController {
            viewController.marketItems = items
            viewController.delegate = self
            let navigation = UINavigationController.init(rootViewController: viewController)
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    @objc func tapMore() {
        let actionSheet = UIAlertController(title: NSLocalizedString("menu", comment: ""), message: nil, preferredStyle: .actionSheet)
        actionSheet.addEmptyCancelAction()
        let editingCustomItems = UIAlertAction(title: NSLocalizedString("editCustomItem", comment: ""), style: .default) { (action) in
            self.performSegue(withIdentifier: String(describing: EditCustomMarketItemsViewController.self), sender: self)
        }
        actionSheet.addAction(editingCustomItems)
        actionSheet.popoverPresentationController?.sourceView = bottomBarView
        actionSheet.popoverPresentationController?.permittedArrowDirections = .down
        present(actionSheet, animated: true, completion: nil)
    }

    @objc func tapCamera() {
        performSegue(withIdentifier: String(describing: AddNewMarketItemViewController.self), sender: self)
    }
    
    @objc func tapDone() {
        let controllers = pagingViewController.viewControllers as! [ErrandViewController]
        for controller in controllers {
            debugPrint(controller.selectedItems)
            let items = [Harvest](controller.selectedItems.values)
            guard FirebaseService.shared.addToErrand(harvests: items) else {
                PurchaseService.shared.alertCapacity()
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigation = segue.destination as? UINavigationController {
            if let addNewItem = navigation.viewControllers.last as? AddNewMarketItemViewController {
                addNewItem.delegate = self
            } else if let editCustomItems = navigation.viewControllers.last as? EditCustomMarketItemsViewController {
                editCustomItems.delegate = self
            }
        }
    }
}

