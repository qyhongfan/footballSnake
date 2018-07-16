//
//  MainViewController.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/16.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import Foundation
import UIKit
import WebKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

class MainViewController: UIViewController {
    var urlString = ""
    var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: webConfiguration)
        return webView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        view.addSubview(webView)
        let backView = UIImageView(image: #imageLiteral(resourceName: "mainBackGroundImage"))
        backView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        let firstButton = createButtons(frame: CGRect(x: 80, y: ScreenHeight/2 - 125, width: ScreenWidth - 160, height: 50), title: "混战模式", action: #selector(toFirstVC))
        let secondButton = createButtons(frame: CGRect(x: 80, y: ScreenHeight/2 - 25, width: ScreenWidth - 160, height: 50), title: "经典模式", action: #selector(toSecondVC))
        view.addSubview(backView)
        view.addSubview(firstButton)
        view.addSubview(secondButton)
    }
    
    private func createButtons(frame: CGRect, title: String, action: Selector) -> UIButton {
        let btn = UIButton()
        btn.layer.cornerRadius = 25
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white, for: .highlighted)
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .highlighted)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 28)
        btn.frame = frame
        return btn
    }
    
    @objc func toFirstVC() {
        let vc = FirstViewController()
        present(vc, animated: true, completion: nil)
    }
    @objc func toSecondVC() {
        let vc = SecondViewController()
        present(vc, animated: true, completion: nil)
    }
    
    func requestAndShow() {
        getWithPath(path: "http://120.78.83.23/index.php?app_id=free_style_football", paras: nil, success: { [weak self] (result) in
            guard let weakSelf = self else { return }
            if let dic = result as? [String: Any] {
                if let arr = dic["url"] as? NSArray, let urlString = arr.firstObject as? String, urlString.count > 5, let url = URL(string: urlString) {
                    print("notification url \(urlString)")
                    DispatchQueue.main.async {
                        weakSelf.view.bringSubview(toFront: weakSelf.webView)
                        weakSelf.webView.load(URLRequest(url: url))
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func showWebView(_ urlString: String) {
        if let url = URL(string: urlString), self.urlString != urlString {
            self.urlString = urlString
            view.bringSubview(toFront: webView)
            webView.load(URLRequest(url: url))
        }
    }
}

extension MainViewController {
    func getWithPath(path: String, paras: Dictionary<String,Any>?,success: @escaping ((_ result: Any?) -> ()),failure: @escaping ((_ error: Error?) -> ())) {
        var i = 0
        var address = path
        if let paras = paras {
            for (key,value) in paras {
                if i == 0 {
                    address += "?\(key)=\(value)"
                }else {
                    address += "&\(key)=\(value)"
                }
                i += 1
            }
        }
        
        let url = URL(string: address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url!) { (data, respond, error) in
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                success(result)
            } else {
                failure(error)
            }
        }
        dataTask.resume()
    }
    
    func convertStringToDictionary(_ text: String) -> [String:Any]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func convertStringToArray(_ text: String) -> [String]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
