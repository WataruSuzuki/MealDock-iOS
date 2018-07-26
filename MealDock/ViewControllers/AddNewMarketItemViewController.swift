//
//  AddNewMarketItemViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

import MaterialComponents.MaterialCollections

class AddNewMarketItemViewController: MDCCollectionViewController {

    var capturePhotoView: UIImageView?
    var cameraButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(MDCCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewCell.self))
        self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewTextCell.self))
        self.collectionView!.register(TextFieldCell.self, forCellWithReuseIdentifier: String(describing: TextFieldCell.self))

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Element.max.rawValue
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        if let section = Element(rawValue: indexPath.section) {
            switch section {
            case .name:
                return textFieldCell(collectionView, cellForItemAt: indexPath, section: section)
                
            case .type:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewTextCell.self), for: indexPath) as! MDCCollectionViewTextCell
                return cell
                
            case .imageUrl:
                return photoCell(collectionView, cellForItemAt: indexPath, section: section)
                
            default:
                break
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    }
    
    fileprivate func textFieldCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Element) -> TextFieldCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TextFieldCell.self), for: indexPath) as! TextFieldCell
        
        if cell.textField.superview == nil {
            cell.inputController = MDCTextInputControllerOutlined(textInput: cell.textField)
            cell.inputController?.placeholderText = NSLocalizedString("title", comment: "")
            cell.addSubview(cell.textField)
            cell.textField.autoPinEdgesToSuperviewEdges()
        }
        
        return cell
    }
    
    fileprivate func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Element) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewCell.self), for: indexPath)
        
        if capturePhotoView == nil {
            capturePhotoView = UIImageView(frame: .zero)
            capturePhotoView!.contentMode = .scaleAspectFit
            cell.addSubview(capturePhotoView!)
            capturePhotoView!.autoPinEdgesToSuperviewEdges()
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = Element(rawValue: indexPath.section) {
            switch section {
            case .imageUrl:
                return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 2)
                
            case .name:
                return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 1.5)
                
            default:
                break
            }
        }
        return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight)
    }
    
    enum Element: Int {
        case name = 0,
        type,
        imageUrl,
        max
    }
}
