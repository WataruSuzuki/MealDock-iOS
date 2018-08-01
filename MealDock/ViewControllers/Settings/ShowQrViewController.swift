//
//  ShowQrViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/14.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import QRCode

class ShowQrViewController: UIViewController {

    let qrImageView = UIImageView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = FirebaseService.shared.currentUser {
            let qrStr = "{ id: \(sha1(param: user.uid)) , name : \(user.displayName ?? "(・∀・)") }"
            if let image = QRCode(qrStr)?.image {
                qrImageView.image = image
                view.addSubview(qrImageView)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        qrImageView.autoSetDimension(.height, toSize: fmin(view.frame.width, view.frame.height))
        qrImageView.autoSetDimension(.width, toSize: fmin(view.frame.width, view.frame.height))
        qrImageView.autoCenterInSuperview()
    }

    private func sha1(param: String) -> String {
        let str = "\(param)_\(NSDate().timeIntervalSince1970)"
        let data = str.data(using: .utf8)!
        let length = Int(CC_SHA1_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        _ = data.withUnsafeBytes { CC_SHA1($0, CC_LONG(data.count), &digest) }
        let crypt = digest.map { String(format: "%02x", $0) }.joined(separator: "")
        debugPrint("crypt : \(crypt)")

        return crypt
    }
}
