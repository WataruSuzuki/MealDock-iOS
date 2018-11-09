//
//  Errand+SearchedPhoto.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/12/18.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

protocol SearchPhotoWebDelegate {
    func searchedPhoto(urls: [String])
}

extension ErrandPagingViewController : SearchPhotoWebDelegate {
    func searchedPhoto(urls: [String]) {
        searchedPhotoUrls = urls
        self.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: String(describing: AddNewMarketItemViewController.self), sender: self)
    }
}
