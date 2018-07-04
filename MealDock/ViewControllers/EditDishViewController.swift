//
//  EditDishViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

private let reuseIdentifier = "EditDishCell"
private let textCellIdentifier = "EditDishTextCell"

class EditDishViewController: MDCCollectionViewController,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    var checkedItems : [Harvest]!
    var titleTextController: MDCTextInputController!
    var descriptionTextController: MDCTextInputController!
    var capturePhotoView: UIImageView?
    var cameraButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(MDCCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: textCellIdentifier)
        self.collectionView!.register(MDCCollectionViewTextCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionElementKindSectionHeader)

        // Do any additional setup after loading the view.
        styler.cellStyle = .card
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "baseline_cancel_black_36pt")!, style: .plain, target: self, action: #selector(tapDismiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "packed_food")!, style: .done, target: self, action: #selector(tapDone))
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
        return Section.max.rawValue
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Section.harvest.rawValue {
            return checkedItems.count
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        if let section = Section(rawValue: indexPath.section) {
            if section == .harvest {
                return harvestCell(collectionView, cellForItemAt: indexPath)
            }
            return materialCollectionCell(collectionView, cellForItemAt: indexPath, section: section)
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    fileprivate func materialCollectionCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Section) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        switch section {
        case .photo:
            if cameraButton == nil {
                cameraButton = UIButton(frame: .zero)
                cameraButton!.setImage(UIImage(named: "baseline_photo_camera_white_48pt"), for: .normal)
                cameraButton!.addTarget(self, action: #selector(tapCamera), for: .touchUpInside)
                cell.addSubview(cameraButton!)
                cameraButton!.autoCenterInSuperview()
            }
            if capturePhotoView == nil {
                capturePhotoView = UIImageView(frame: .zero)
                capturePhotoView!.contentMode = .scaleAspectFit
                cell.addSubview(capturePhotoView!)
                capturePhotoView!.autoPinEdgesToSuperviewEdges()
            }
            
        case .title:
            let textField = MDCTextField(frame: .zero)
            titleTextController = MDCTextInputControllerOutlined(textInput: textField)
            titleTextController.placeholderText = NSLocalizedString("title", comment: "")
            cell.addSubview(textField)
            textField.autoPinEdgesToSuperviewEdges()
            
        case .description:
            let multiLineField = MDCMultilineTextField(frame: .zero)
            descriptionTextController = MDCTextInputControllerOutlinedTextArea(textInput: multiLineField)
            descriptionTextController.placeholderText = NSLocalizedString("description", comment: "")
            cell.addSubview(multiLineField)
            multiLineField.autoPinEdgesToSuperviewEdges()
            
        default:
            break
        }
        
        return cell
    }
    
    fileprivate func harvestCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MDCCollectionViewTextCell {
        let textCell = collectionView.dequeueReusableCell(withReuseIdentifier: textCellIdentifier, for: indexPath) as! MDCCollectionViewTextCell
        textCell.textLabel?.text = checkedItems[indexPath.row].name
        textCell.imageView?.image = UIImage(named: "harvest")
        textCell.imageView?.setImageByAlamofire(with: URL(string: checkedItems[indexPath.row].imageUrl)!)

        return textCell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = Section(rawValue: indexPath.section) {
            switch section {
            case .photo:
                return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.width)
                
            case .title:
                return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 1.5)

            case .description:
                return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight * 3)
                
            default:
                break
            }
        }
        return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! MDCCollectionViewTextCell
        if kind == UICollectionElementKindSectionHeader {
            if let section = Section(rawValue: indexPath.section) {
                view.textLabel?.text = NSLocalizedString(section.toString(), comment: "")
            }
        }
        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section != Section.harvest.rawValue {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight)
        }
    }
    /*
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            capturePhotoView?.image = image
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: Actions
    
    @objc func tapCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func tapDone() {
        if let image = capturePhotoView?.image {
            FirebaseService.shared.uploadDishPhoto(image: image, contentType: "image/png")
        }
        dismiss(animated: true, completion: nil)
    }
    
    enum Section: Int {
        case photo = 0,
        title,
        description,
        harvest,
        max
        
        func toString() -> String {
            return String(describing: self)
        }
    }
}
