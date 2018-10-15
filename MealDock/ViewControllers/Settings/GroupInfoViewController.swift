//
//  GroupInfoViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/14.
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

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        FirebaseService.shared.observeMyDockMember { (members) in
            self.dockMembers = members
            self.tableView.reloadSections(IndexSet(integer: Sections.invitedMembers.rawValue), with: .automatic)
        }
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
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(managing.description(), comment: "")
                }

            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groupInfo = Sections(rawValue: section) {
            return NSLocalizedString(groupInfo.description(), comment: "")
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
            tableView.deleteRows(at: [indexPath], with: .fade)
        //} else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .manageGrouping:
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    switch managing {
                    case .addNewMember:
                        scanQR()
                    case .requestToJoin:
                        generateQR()
                    case .leaveFromGroup:
                        FirebaseService.shared.joinToGroupDock(dock: nil, id: nil)
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
            debugPrint(result ?? "not found QRCodeReaderResult")
            guard let result = result else {
                print("Not found QRCodeReaderResult")
                self.dismiss(animated: true, completion: nil)
                return
            }
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
                print(error)
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
        case addNewMember = 0,
        requestToJoin,
        leaveFromGroup,
        max
    }
}
