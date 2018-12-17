//
//  GroupInfoViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/14.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import QRCodeReader

class GroupInfoViewController: UITableViewController {

    lazy var qrReader: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    var dockMembers = [DockMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isGroupOwnerNow() {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        FirebaseService.shared.observeMyDockMember { (members) in
            self.dockMembers = members
            self.tableView.reloadSections(IndexSet(integer: Sections.invitedMembers.rawValue), with: .automatic)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseService.shared.removeMemberObsever()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupInfo = Sections(rawValue: section) {
            switch groupInfo {
            case .invitedMembers:
                return dockMembers.count
                
            case .manageGrouping:
                return ManageStatus.max.rawValue
                
            default:
                break
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoCell", for: indexPath)

        // Configure the cell...
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .invitedMembers:
                cell.textLabel?.text = dockMembers[indexPath.row].name

            case .manageGrouping:
                cell.accessoryType = .detailButton
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    cell.textLabel?.text = managing.description().localized
                    switch managing {
                    case .groupOwner:
                        cell.textLabel?.isEnabled = true
                        cell.selectionStyle = .none
                        cell.accessoryType = .none
                        if cell.accessoryView == nil {
                            let ownerSwitch = UISwitch(frame: .zero)
                            ownerSwitch.isOn = isGroupOwnerNow()
                            ownerSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
                            cell.accessoryView = ownerSwitch
                            FirebaseService.shared.currentUser?.switchingDock = { (dock) in
                                self.tableView.reloadSections(IndexSet(integer: Sections.manageGrouping.rawValue), with: .automatic)
                            }
                        }

                    case .addNewMember:
                        cell.accessoryView = nil
                        cell.isUserInteractionEnabled = isGroupOwnerNow()
                        cell.textLabel?.isEnabled = isGroupOwnerNow()
                        cell.selectionStyle = (isGroupOwnerNow() ? .default : .none)
                    default:
                        cell.accessoryView = nil
                        cell.isUserInteractionEnabled = !isGroupOwnerNow()
                        cell.textLabel?.isEnabled = !isGroupOwnerNow()
                        cell.selectionStyle = (isGroupOwnerNow() ? .none : .default)
                    }
                }

            default:
                break
            }
        }

        return cell
    }
    
    @objc func switchTriggered(sender: UISwitch){
        if !sender.isOn {
            FirebaseService.shared.joinToGroupDock(dock: "temp", id: "temp")
        } else {
            let controller = UIAlertController(title: "(・A・)", message: "msg_remove_joining_info".localized, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
            let removeAction = UIAlertAction(title: "Execute", style: .destructive) { (action) in
                FirebaseService.shared.joinToGroupDock(dock: nil, id: nil)
            }
            controller.addAction(removeAction)
            controller.addCancelAction { (action) in
                self.tableView.reloadSections(IndexSet(integer: Sections.manageGrouping.rawValue), with: .automatic)
            }
            present(controller, animated: true, completion: nil)
        }
    }
    
    private func isGroupOwnerNow() -> Bool {
        if let user = FirebaseService.shared.currentUser, user.isGroupOwnerMode {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groupInfo = Sections(rawValue: section) {
            return groupInfo.description().localized
        }
        return nil
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.invitedMembers.rawValue
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            FirebaseService.shared.deleteDockMember(memberId: dockMembers[indexPath.row].id)
            dockMembers.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        //} else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .manageGrouping:
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    let alert = UIAlertController(title: "", message: ("detailButton_" + managing.description()).localized, preferredStyle: .alert)
                    alert.addEmptyOkAction()
                    present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .manageGrouping:
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    switch managing {
                    case .addNewMember:
                        if isGroupOwnerNow() {
                            scanQR()
                        }
                    case .requestToJoin:
                        if !isGroupOwnerNow() {
                            generateQR()
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case String(describing: ShowQrViewController.self):
                if let destination = segue.destination as? UINavigationController,
                    let showQR = destination.viewControllers.last as? ShowQrViewController {
                    showQR.qrType = ShowQrViewController.QrType.requestToJoin
                }
            default:
                break
            }
        }
    }

    // MARK: - QRCodeReaderViewControllerDelegate
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        debugPrint(result)
    }
    
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func scanQR() {
        qrReader.completionBlock = { (result: QRCodeReaderResult?) in
            guard let result = result else {
                print("Not found QRCodeReaderResult")
                self.dismiss(animated: true, completion: nil)
                return
            }
            debugPrint(result)
            do {
                let data = result.value.data(using: .utf8)!
                let handshakeQR = try JSONDecoder().decode(GroupHandshakeQR.self, from: data)
                FirebaseService.shared.addMyDockGroupMember(memberId: handshakeQR.id, name: handshakeQR.name ?? "(・∀・)")
                let sb = UIStoryboard(name: "GroupInfo", bundle: Bundle.main)
                if let viewController = sb.instantiateViewController(withIdentifier: String(describing: ShowQrViewController.self)) as? ShowQrViewController {
                    viewController.qrType = ShowQrViewController.QrType.tellDockId
                    let navigation = UINavigationController.init(rootViewController: viewController)
                    self.qrReader.present(navigation, animated: true, completion: nil)
                }
            } catch let error {
                OptionalError.alertErrorMessage(error: error)
            }
        }
        
        // Presents the qrReader as modal form sheet
        qrReader.modalPresentationStyle = .formSheet
        present(qrReader, animated: true, completion: nil)
    }
    
    func generateQR() {
        performSegue(withIdentifier: String(describing: ShowQrViewController.self), sender: self)
    }
    
    enum Sections: Int {
        case invitedMembers = 0,
        manageGrouping,
        max
    }
    
    enum ManageStatus: Int {
        case groupOwner = 0,
        addNewMember,
        requestToJoin,
        max
    }
}
