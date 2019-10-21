//
//  AboutChild.swift
//  HopliteChallenge
//
//  Created by Jeremy on 10/20/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

class AboutChildViewController: UIViewController {

    var webView = UIWebView()
    var htmlFileName:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if htmlFileName != nil
        {
            if let htmlFile = Bundle.main.path(forResource: htmlFileName!, ofType: "html")
            {
                if let html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)
                {
                    let path = Bundle.main.bundlePath
                    let baseURL = URL(fileURLWithPath: path)
                    webView.loadHTMLString(html, baseURL: baseURL)
                }
            }
        }
    }
}
