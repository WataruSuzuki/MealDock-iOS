//
//  CaptureBarcodeViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/07/30.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

class SearchPhotoWebViewController: UIViewController,
    WKNavigationDelegate
{
    let wkwebview = WKWebView()
    var barcode: String?
    var delegate: SearchPhotoWebDelegate?
    var indicator: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        wkwebview.navigationDelegate = self
        view.addSubview(wkwebview)
        wkwebview.autoPinEdgesToSuperviewEdges()
        if let barcode = barcode {
            wkwebview.load(URLRequest(url: URL(string: "https://www.google.com/search?tbm=isch&q=\(barcode)")!))
            indicator = UIViewController.topIndicatorStart()
        } else {
            self.delegate?.searchedPhoto(urls: [String]())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML") { [weak self] (html, error) in
            var urls = [String]()
            if let html = html as? String {
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
                
                for match in matches {
                    guard let range = Range(match.range, in: html) else { continue }
                    let url = String(html[range])
                    if url.contains(".png")
                        || url.contains(".PNG")
                        || url.contains(".JPG")
                        || url.contains(".jpeg")
                        || url.contains(".jpg") {
                        if url.contains("?") {
                            urls.append(url.components(separatedBy: "?")[0])
                        } else {
                            urls.append(url)
                        }
                    }
                }
            }
            UIViewController.topIndicatorStop(view: self?.indicator)
            self?.delegate?.searchedPhoto(urls: urls)
        }
    }
}

