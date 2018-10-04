//
//  EditDishViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

//private let reuseIdentifier = "EditDishCell"
//private let textCellIdentifier = "EditDishTextCell"

class EditDishViewController: MDCCollectionViewController,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    var checkedItems : [Harvest]!
    var capturePhotoView: UIImageView?
    var cameraButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(MDCCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewCell.self))
        self.collectionView!.register(MDCCollectionViewTextCell.self, forCellWithReuseIdentifier: String(describing: MDCCollectionViewTextCell.self))
        self.collectionView!.register(TextFieldCell.self, forCellWithReuseIdentifier: String(describing: TextFieldCell.self))
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
            switch section {
            case .harvest:
                return harvestCell(collectionView, cellForItemAt: indexPath)
            case .title: fallthrough
            case .description:
                return textFieldCell(collectionView, cellForItemAt: indexPath, section: section)

            case .photo:
                return photoCell(collectionView, cellForItemAt: indexPath, section: section)
                
            default:
                break
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewCell.self), for: indexPath)
    }
    
    fileprivate func textFieldCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Section) -> TextFieldCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TextFieldCell.self), for: indexPath) as! TextFieldCell
        switch section {
        case .title:
            if cell.textField.superview == nil {
                cell.inputController = MDCTextInputControllerOutlined(textInput: cell.textField)
                cell.inputController?.placeholderText = NSLocalizedString("title", comment: "")
                cell.addSubview(cell.textField)
                cell.textField.autoPinEdgesToSuperviewEdges()
            }
            
        case .description:
            if cell.multiLineField.superview == nil {
                cell.inputController = MDCTextInputControllerOutlinedTextArea(textInput: cell.multiLineField)
                cell.inputController?.placeholderText = NSLocalizedString("description", comment: "")
                cell.addSubview(cell.multiLineField)
                cell.multiLineField.autoPinEdgesToSuperviewEdges()
            }
            
        default:
            break
        }
        
        return cell
    }
    
    fileprivate func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, section: Section) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewCell.self), for: indexPath)
        
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
            
        default:
            break
        }
        
        return cell
    }
    
    fileprivate func harvestCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MDCCollectionViewTextCell {
        let textCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCCollectionViewTextCell.self), for: indexPath) as! MDCCollectionViewTextCell
        let harvest = checkedItems[indexPath.row]
        textCell.textLabel?.text = NSLocalizedString(harvest.name, tableName: "MarketItems", comment: "")
        textCell.imageView?.image = UIImage(named: "harvest")
        if let url = URL(string: harvest.imageUrl) {
            textCell.imageView?.setImageByAlamofire(with: url)
        }

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
        #if arch(i386) || arch(x86_64)
        let type = UIImagePickerController.SourceType.photoLibrary
        #else
        let type = UIImagePickerController.SourceType.camera
        #endif
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let picker = UIImagePickerController()
            picker.sourceType = type
            picker.allowsEditing = true
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func tapDone() {
        let alert = UIAlertController(title: "(=・∀・=)", message: NSLocalizedString("msg_saving_data", comment: ""), preferredStyle: .alert)
        let _ = alert.view.startIndicator()
        present(alert, animated: true, completion: nil)
        
        GooglePhotosService.shared.uploadDishPhoto(image: capturePhotoView?.image, uploadedMediaId: { (path) in
            FirebaseService.shared.addDish(dish: self.generateDishData(path: path))
            alert.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }) { (error) in
            alert.dismiss(animated: true, completion: {
                if let error = error {
                    OptionalError.alertErrorMessage(error: error)
                } else {
                    OptionalError.alertErrorMessage(message: NSLocalizedString("failed_save_photo", comment: ""), actions: nil)
                }
            })
        }
    }
    
    private func generateDishData(path: String) -> Dish {
        var title: String!
        var description: String!
        for section in Section.allCases {
            if let cell = collectionView?.cellForItem(at: IndexPath(row: 0, section: section.rawValue)) as? TextFieldCell {
                switch section {
                case .title:
                    if let text = cell.textField.text, !text.isEmpty {
                        title = text
                    } else {
                        title = getCurrentTimeStr()
                    }
                case .description:
                    description = cell.multiLineField.text
                default:
                    break
                }
            }
        }
        return Dish(title: title, description: description, imagePath: path, harvest: checkedItems)
    }
    
    private func getCurrentTimeStr() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: Date()).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: " ", with: "_")
    }
    
    enum Section: Int, CaseIterable {
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
