//
//  UIViewController+FAB.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialButtons_ColorThemer

extension UIViewController {
    
    func activateFab(fab: MDCFloatingButton, target: Any?, image: UIImage, selector: Selector) {
        fab.setImage(image, for: .normal)
        fab.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func layout(fab: MDCFloatingButton) {
        fab.centerXToSuperview()
        if let targetOf = tabBarController?.tabBar {
            //fab.autoPinEdge(.trailing, to: .trailing, of: targetOf, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: targetOf, withOffset: -20)
        } else {
            //fab.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -30)
            fab.autoPinEdge(.bottom, to: .top, of: self.view, withOffset: -20)
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
                
                let contoller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                contoller.excludedActivityTypes = [
                    UIActivityType.postToWeibo,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.print
                ]
                if let top = UIViewController.currentTop() {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        contoller.popoverPresentationController?.sourceView = top.view
                        contoller.popoverPresentationController?.sourceRect = top.view.frame
                    }
                    top.present(contoller, animated: true, completion: nil)
                }
                
            }
            action.handler = actionHandler
            action.title = NSLocalizedString("share", comment: "")
            message.action = action
        }
        
        MDCSnackbarManager.show(message)
    }
}
