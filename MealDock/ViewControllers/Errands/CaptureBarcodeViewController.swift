//
//  CaptureBarcodeViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import BarcodeScanner

class CaptureBarcodeViewController: UIViewController,
    BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate
{

    var barcodeScanner: BarcodeScannerViewController? = BarcodeScannerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let controller = barcodeScanner {
            controller.codeDelegate = self
            controller.errorDelegate = self
            controller.dismissalDelegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        controller.reset()
        controller.dismiss(animated: true, completion: nil)
        barcodeScanner = nil
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    }
}

