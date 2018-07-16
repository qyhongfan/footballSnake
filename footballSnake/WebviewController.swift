//
//  WebviewController.swift
//  HePai
//
//  Created by 刘滔 on 16/5/10.
//  Copyright © 2016年 DJI. All rights reserved.
//

/*
 *  MiniappViewController 继承自 WebViewController
 */

import UIKit
import WebKit

class WebViewController: UIViewController {

    let webview: WKWebView = {
        let prefs = WKPreferences()
        prefs.javaScriptCanOpenWindowsAutomatically = true
        
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        config.allowsInlineMediaPlayback = true
        if #available(iOS 9.0, *) {
            config.requiresUserActionForMediaPlayback = true
            config.allowsPictureInPictureMediaPlayback = true
            config.allowsAirPlayForMediaPlayback = true
            
        }
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        return webView
    }()
    
    var url: String!
    
    convenience init(url: String) {
        self.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.frame = UIScreen.main.bounds
        webview.navigationDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        webview.scrollView.showsHorizontalScrollIndicator = false
        webview.scrollView.showsVerticalScrollIndicator = false
        view.addSubview(webview)
        if let url = URL(string: url) {
            webview.load(URLRequest(url: url))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func loadUrlRequest(_ url: String) {
        if let url = URL(string: url) {
            webview.load(URLRequest(url: url))
        }
    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 开始加载
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 加载完毕
        finishLoading()
        navigationItem.rightBarButtonItem?.isEnabled = true
        if let webTitle = webview.title {
            title = webTitle
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 加载失败
        finishLoading()
        
        if let webTitle = webview.title {
            title = webTitle
        }
    }
    
    func finishLoading() {

    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if webView != self.webview {
            return
        }
        guard let _ = navigationAction.request.url else {
            return
        }
        
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}


