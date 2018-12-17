//
//  Errand+CaptureBarcode.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/12/18.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import BarcodeScanner

extension ErrandPagingViewController : BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        debugPrint(code)
        barcode = code
        controller.reset()
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: String(describing: SearchPhotoWebViewController.self), sender: self)
        }
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.reset()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func presentBarcodeScanner() {
        barcodeScanner.codeDelegate = self
        barcodeScanner.errorDelegate = self
        barcodeScanner.dismissalDelegate = self
        barcodeScanner.headerViewController.customBarButtonItem = UIBarButtonItem(title: "skip".localized, style: .plain, target: self, action: #selector(tapSkip))
        present(barcodeScanner, animated: true, completion: nil)
    }
    
    @objc func tapSkip() {
        barcodeScanner.dismiss(animated: true) {
            self.performSegue(withIdentifier: String(describing: SearchPhotoWebViewController.self), sender: self)
        }
    }
}
