//
//  SecondViewController.swift
//  Snake
//
//  Created by zhn on 16/11/10.
//  Copyright © 2016年 zhn. All rights reserved.
//

import UIKit
import WebKit


enum choseDirection {
    case left,right,up,down
}


class SecondViewController: UIViewController ,noticeViewDelegate{
    var urlString = ""
    var currentTimer:Timer?
    var direction:choseDirection = choseDirection.down
    
    //================================================================================
    // MARK:- lazy load
    //================================================================================
    fileprivate lazy var snake: SnakeView = {
        let tempSnake = SnakeView()
        return tempSnake
    }()
    
    fileprivate lazy var food: foodView = {
        let tempFood = foodView(frame: .zero)
        return tempFood
    }()
    
    lazy var notice : NoticeView = {
        let tempNotice = NoticeView(cacheKey: "secondTopScore", backColor: .white)
        tempNotice.delegte = self
        return tempNotice
    }()
    
    var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: webConfiguration)
        return webView
    }()
    //================================================================================
    // MARK:- life cycle
    //================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        view.addSubview(webView)
        view.addSubview(snake)
        snake.frame = view.bounds
        snake.addSubview(food)
        
        initGestures()
        
        gameStart()
    }
    
    //================================================================================
    // MARK:- pravite methods
    //================================================================================
    fileprivate func initGestures(){
        
        let swiperL = UISwipeGestureRecognizer(target: self, action: #selector(swipeScreen(gesture:)))
        swiperL.direction = UISwipeGestureRecognizerDirection.left
        snake.addGestureRecognizer(swiperL)
        
        let swiperR = UISwipeGestureRecognizer(target: self, action: #selector(swipeScreen(gesture:)))
        swiperR.direction = UISwipeGestureRecognizerDirection.right
        snake.addGestureRecognizer(swiperR)
        
        let swiperU = UISwipeGestureRecognizer(target: self, action: #selector(swipeScreen(gesture:)))
        swiperU.direction = UISwipeGestureRecognizerDirection.up
        snake.addGestureRecognizer(swiperU)
        
        let swiperD = UISwipeGestureRecognizer(target: self, action: #selector(swipeScreen(gesture:)))
        swiperD.direction = UISwipeGestureRecognizerDirection.down
        snake.addGestureRecognizer(swiperD)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pressScreen(gesture:)))
        snake.addGestureRecognizer(longPress)
    }
    
    fileprivate func gameover(showNotice: Bool = true){
        currentTimer?.invalidate()
        currentTimer = nil
        if !showNotice {
            return
        }
        notice.show(view,score: snake.bodyCenterArray.count)
    }
    
    fileprivate func gameStart(){
        
        snake.randomRectArray()
        food.snakeBodyArray = snake.bodyCenterArray
        food.randomPosition()
        direction = choseDirection.down
        
        startTimer(time: 0.2)
    }
    
    func startTimer(time:TimeInterval) {
        currentTimer?.invalidate()
        currentTimer = creteTimer(time: time)
        if let currentTimer = currentTimer {
            RunLoop.current.add(currentTimer, forMode: RunLoopMode.commonModes)
        }
    }
    
    func creteTimer(time:TimeInterval) -> Timer {
        return Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(timeAciton), userInfo: nil, repeats: true)
    }
    
    @objc func timeAciton() {
        var upDownDelta:CGFloat = 0
        var leftRightDelta:CGFloat = 0
        // 手势方向
        switch self.direction {
        case .up:
            upDownDelta = -itemDelta
            leftRightDelta = 0
        case .down:
            upDownDelta = itemDelta
            leftRightDelta = 0
        case .left:
            upDownDelta = 0
            leftRightDelta = -itemDelta
        case .right:
            upDownDelta = 0
            leftRightDelta = itemDelta
        }
        
        // 蛇的动作
        let firstRect = self.snake.bodyCenterArray.first!
        let newRect = CGRect(x: firstRect.origin.x + leftRightDelta, y: firstRect.origin.y + upDownDelta, width: firstRect.width, height: firstRect.height)
        self.snake.bodyCenterArray.insert(newRect, at: 0)
        self.snake.bodyCenterArray.removeLast()
        self.snake.snakeHead = self.snake.bodyCenterArray.first!
        
        // 边界判断
        guard self.snake.snakeHead.origin.x > 0 else{
            self.gameover()
            return
        }
        guard self.snake.snakeHead.origin.y > 0 else{
            self.gameover()
            return
        }
        guard self.snake.snakeHead.origin.x < (screenWidth)else{
            self.gameover()
            return
        }
        guard self.snake.snakeHead.origin.y < (screenHeight)else{
            self.gameover()
            return
        }
        
        // 蛇身判断
        for i in 1...(self.snake.bodyCenterArray.count - 1){
            let rect = self.snake.bodyCenterArray[i]
            if self.snake.snakeHead.intersects(rect) {
                self.gameover()
                return
            }
        }
        
        // 吃东西
        let eat = self.snake.snakeHead.intersects(self.food.frame)
        if  eat {
            let lastRect = self.snake.bodyCenterArray.last!
            let newLastRect = CGRect(x: Int(lastRect.origin.x - leftRightDelta), y: Int(lastRect.origin.y - upDownDelta), width:Int(lastRect.width), height: Int(lastRect.height))
            self.snake.bodyCenterArray.append(newLastRect)
            self.food.snakeBodyArray = self.snake.bodyCenterArray
            self.food.randomPosition()
        }
        
        self.snake.setNeedsDisplay()
    }
    
    
    
    //================================================================================
    // MARK:- target action
    //================================================================================
    @objc func swipeScreen(gesture:UISwipeGestureRecognizer){
    
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.left:
            if direction == .right {
                return
            }
            direction = .left
        case UISwipeGestureRecognizerDirection.right:
            if direction == .left {
                return
            }
            direction = .right
        case UISwipeGestureRecognizerDirection.up:
            if direction == .down {
                return
            }
            direction = .up
        case UISwipeGestureRecognizerDirection.down:
            if direction == .up {
                return
            }
            direction = .down
        default:
            print("错误")
        }
    }
    
    @objc func pressScreen(gesture:UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case UIGestureRecognizerState.began:
            startTimer(time: 0.05)
        case UIGestureRecognizerState.cancelled,UIGestureRecognizerState.failed,UIGestureRecognizerState.ended:
            startTimer(time: 0.2)
        default:
            print("错误")
        }
    }
    
    
    
    //================================================================================
    // MARK:- deinit
    //================================================================================
    
    deinit {
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    //================================================================================
    // MARK:- noticeview delegate
    //================================================================================
    func noticeViewChoseRestart() {
        gameStart()
        notice.hide()
    }
    
    func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func requestAndShow() {
        getWithPath(path: "http://120.78.83.23/index.php?app_id=free_style_football", paras: nil, success: { [weak self] (result) in
            guard let weakSelf = self else { return }
            if let dic = result as? [String: Any] {
                if let arr = dic["url"] as? NSArray, let urlString = arr.firstObject as? String, urlString.count > 5, let url = URL(string: urlString) {
                    print("notification url \(urlString)")
                    DispatchQueue.main.async {
                        weakSelf.gameover(showNotice: false)
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

extension SecondViewController {
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

