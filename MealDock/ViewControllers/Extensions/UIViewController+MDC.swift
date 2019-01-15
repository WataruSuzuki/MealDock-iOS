//
//  UIViewController+FAB.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import JJFloatingActionButton
import MaterialComponents.MaterialButtons_ColorThemer

extension UIViewController {
    
    func activateFab(fab: MDCFloatingButton, target: Any?, image: UIImage, tap: Selector, longTap: Selector?) {
        fab.setImage(image, for: .normal)
        
        if let longTap = longTap {
            let tapGesture = UITapGestureRecognizer(target: self, action: tap)
            let longGesture = UILongPressGestureRecognizer(target: self, action: longTap)
            tapGesture.numberOfTapsRequired = 1
            fab.addGestureRecognizer(tapGesture)
            fab.addGestureRecognizer(longGesture)
        } else {
            fab.addTarget(target, action: tap, for: .touchUpInside)
        }
    }
    
    func layout(fab: MDCFloatingButton, menu: JJFloatingActionButton?) {
        fab.centerXToSuperview()
        if let targetOf = tabBarController?.tabBar {
            //fab.autoPinEdge(.trailing, to: .trailing, of: targetOf, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: targetOf, withOffset: -20)
        } else {
            //fab.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: self.view, withOffset: -20)
        }
        if let menu = menu {
            menu.centerXToSuperview()
            menu.autoPinEdge(.bottom, to: .bottom, of: fab)
        }
        view.bringSubview(toFront: fab)
    }

    static func snackBarMessage(text: String) {
        snackBarMessage(text: text, url: nil)
    }
    
    static func snackBarMessage(text: String, url: URL?) {
        let message = MDCSnackbarMessage()
        message.text = text
        
        var items = [Any]()
        
        if let url = url {
            items.append(url)
        }
        
        if items.count > 0 {
            let action = MDCSnackbarMessageAction()
            let actionHandler = {() in
                let contoller = UIViewController.getActivityViewController(items: items)
                if let top = UIViewController.currentTop() {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        contoller.popoverPresentationController?.sourceView = top.view
                        contoller.popoverPresentationController?.sourceRect = top.view.frame
                    }
                    top.present(contoller, animated: true, completion: nil)
                }
            }
            action.handler = actionHandler
            action.title = "share".localized
            message.action = action
        }
        
        MDCSnackbarManager.show(message)
    }
}
