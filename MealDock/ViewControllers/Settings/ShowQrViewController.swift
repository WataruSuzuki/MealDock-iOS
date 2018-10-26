//
//  ShowQrViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/14.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import QRCode
import QRCodeReader

class ShowQrViewController: UIViewController,
    QRCodeReaderViewControllerDelegate
{

    let qrImageView = UIImageView(frame: .zero)
    lazy var qrReader: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    var qrType: QrType!
    var joinUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tapDismiss))
        switch qrType! {
        case .requestToJoin:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanQR))
        case .tellDockId:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDone))
        }
        if let user = FirebaseService.shared.currentUser,
            let qrStr = generateQRMessage(user: user, type: qrType) {
            if let image = QRCode(qrStr)?.image {
                qrImageView.image = image
                view.addSubview(qrImageView)
                return
            }
        }
        let failedAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        OptionalError.alertErrorMessage(message: NSLocalizedString("failed_generate_qr", comment: ""), actions: [failedAction])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        qrImageView.autoSetDimension(.height, toSize: fmin(view.frame.width, view.frame.height))
        qrImageView.autoSetDimension(.width, toSize: fmin(view.frame.width, view.frame.height))
        qrImageView.autoCenterInSuperview()
    }
    
    func generateQRMessage(user: DockUser, type: QrType) -> String? {
        var jsonObj: [String : String]!
        switch type {
        case .requestToJoin:
            joinUid = user.core.uid.sha1(with: String(NSDate().timeIntervalSince1970))
            jsonObj = ["id": joinUid, "name": user.core.displayName ?? "(・∀・)"]
        case .tellDockId:
            jsonObj = ["id": user.core.uid, "name": user.core.displayName ?? "(・∀・)"]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
            return String(bytes: jsonData, encoding: .utf8)!
        } catch let error {
            print(error)
            return nil
        }
    }

    @objc func tapDone() {
        self.presentingViewController?
            .presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - QRCodeReaderViewControllerDelegate
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        debugPrint(result)
        guard let data = result.value.data(using: .utf8) else { return }
        
        do {
            let handshakeQR = try JSONDecoder().decode(GroupHandshakeQR.self, from: data)
            FirebaseService.shared.joinToGroupDock(dock: handshakeQR.id, id: joinUid)
            self.dismiss(animated: true, completion: {
                self.dismiss(animated: false, completion: nil)
            })
        } catch let error {
            OptionalError.alertErrorMessage(error: error)
        }
    }
    
//    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
//        if let cameraName = newCaptureDevice.device.localizedName {
//            print("Switching capturing to: \(cameraName)")
//        }
//    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func scanQR() {
        // Retrieve the QRCode content
        // By using the delegate pattern
        qrReader.delegate = self
        
        // Or by using the closure pattern
        //qrReader.completionBlock = { (result: QRCodeReaderResult?) in
            //bla bla bla
        //}
        
        // Presents the qrReader as modal form sheet
        qrReader.modalPresentationStyle = .formSheet
        present(qrReader, animated: true, completion: nil)
    }
    
    enum QrType {
        case requestToJoin,
        tellDockId
    }
}
