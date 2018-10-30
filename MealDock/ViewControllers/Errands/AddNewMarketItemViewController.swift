//
//  AddNewMarketItemViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import ActionSheetPicker_3_0

class AddNewMarketItemViewController: MDCCollectionViewController {

    var capturePhotoView: UIImageView?
    var cameraButton: UIButton?
    var typePicker: UIPickerView?
    var selectedType = Harvest.Section.unknown
    var items: [String]?
    var delegate: UpdateCustomMarketItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("addNewMarketItem", comment: "")        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(MDCCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewCell.self))
        self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewTextCell.self))
        self.collectionView!.register(TextFieldCell.self, forCellWithReuseIdentifier: String(describing: TextFieldCell.self))
        self.collectionView!.register(PickerCell.self, forCellWithReuseIdentifier: String(describing: PickerCell.self))
        self.collectionView!.register(MDCCollectionViewTextCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionElementKindSectionHeader)

        // Do any additional setup after loading the view.
        styler.cellStyle = .card
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(tapSave))
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
                return viewTextCell(collectionView, cellForItemAt: indexPath, section: section)
                
//            case .imageUrl:
//                return photoCell(collectionView, cellForItemAt: indexPath, section: section)
                
            default:
                break
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    }
    
    fileprivate func viewTextCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Element) -> MDCCollectionViewTextCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewTextCell.self), for: indexPath) as! MDCCollectionViewTextCell
        cell.textLabel?.text = selectedType.emoji()
        return cell
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
    
    fileprivate func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Element) -> MDCCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewCell.self), for: indexPath) as! MDCCollectionViewCell
        
        if capturePhotoView == nil {
            capturePhotoView = UIImageView(frame: .zero)
            capturePhotoView!.contentMode = .scaleAspectFit
            cell.addSubview(capturePhotoView!)
            capturePhotoView!.autoPinEdgesToSuperviewEdges()
            capturePhotoView?.isHidden = true
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = Element(rawValue: indexPath.section) {
            switch section {
//            case .imageUrl:
//                return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.width / 2)
                
            case .name:
                return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 1.5)
                
            case .type:
                if let cell = collectionView.cellForItem(at: indexPath) as? PickerCell {
                    if !cell.picker.isHidden {
                        return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 1.5 + cell.picker.frame.height)
                    }
                }
                fallthrough
                
            default:
                break
            }
        }
        return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Element.type.rawValue {
            if let cell = collectionView.cellForItem(at: indexPath) as? MDCCollectionViewTextCell {
                if items == nil {
                    items = [String]()
                    for index in 0..<Harvest.Section.max.rawValue {
                        let section = Harvest.Section(rawValue: index)!
                        items!.append(section.emoji())
                    }
                }
                ActionSheetStringPicker.show(withTitle: "(・∀・)", rows: items!, initialSelection: 1, doneBlock: {
                    picker, value, index in
                    DispatchQueue.main.async {
                        self.selectedType = Harvest.Section(rawValue: value)!
                        collectionView.reloadItems(at: [indexPath])
                    }
                }, cancel: { ActionStringCancelBlock in }, origin: cell)
            }
        }
    }
    
    @objc func tapSave() {
        guard let cell = collectionView?.cellForItem(at: IndexPath(item: 0, section: Element.name.rawValue)) as? TextFieldCell, let name = cell.textField.text, !name.isEmpty else {
            OptionalError.alertErrorMessage(message: NSLocalizedString("msg_necessary_name", comment: ""), actions: nil)
            return
        }
        let harvest = Harvest(name: name, section: selectedType.toString(), imageUrl: "")
        guard FirebaseService.shared.addCustomMarketItem(harvests: [harvest]) else {
            PurchaseService.shared.alertCapacity()
            return
        }
        delegate?.updatedItem()
    }
    
    enum Element: Int {
        case name = 0,
        type,
        //imageUrl,
        max
        
        func toString() -> String {
            return String(describing: self)
        }
    }
}
