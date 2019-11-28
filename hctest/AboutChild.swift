//
//  AboutChild.swift
//  HopliteChallenge
//
//  Created by Jeremy on 10/20/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit
import WebKit

class AboutChildViewController: UIViewController {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                resetColors()
            }
        }
    }
    
    func resetColors()
    {
        GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
        //view.backgroundColor = GlobalTheme.primaryBG //not needed?
        webView.backgroundColor = GlobalTheme.primaryBG
    }
    
    var webView = WKWebView() //UIWebView()
    var htmlFileName:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prevent flashing in dark mode
        //https://forums.developer.apple.com/thread/121139
        webView.isOpaque = false

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
                if var html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)
                {
                    if htmlFileName == "tutorialTitlePage"
                    {
                        var realVersion = ""
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                        {
                            //NSLog("Version: \(version)")
                            realVersion = "<div>Version: " + version + "</div>"
                        }
                        html = html.replacingOccurrences(of: "%version%", with: realVersion)
                    }
                    
                    let path = Bundle.main.bundlePath
                    let baseURL = URL(fileURLWithPath: path)
                    webView.loadHTMLString(html, baseURL: baseURL)
                }
            }
        }
        resetColors()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard let url = request.url, navigationType == .linkClicked else { return true }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
        return false
    }
    
}
