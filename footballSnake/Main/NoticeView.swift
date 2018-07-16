//
//  noticeView.swift
//  Snake
//
//  Created by zhn on 16/11/11.
//  Copyright © 2016年 zhn. All rights reserved.
//

import UIKit

@objc protocol noticeViewDelegate {
    @objc func noticeViewChoseRestart()
    @objc func onBack()
}

class NoticeView: UIView {
    weak var delegte:noticeViewDelegate?
    var cacheKey: String!
    //================================================================================
    // MARK:- laze load
    //================================================================================
    lazy var startBtn:UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(restartBtn), for: UIControlEvents.touchUpInside)
        btn.setTitle("重新开始", for: UIControlState.normal)
        btn.backgroundColor = UIColor.black
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var backBtn:UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(onBack), for: UIControlEvents.touchUpInside)
        btn.setTitle("返回", for: UIControlState.normal)
        btn.backgroundColor = UIColor.black
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.text = "GAME OVER"
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 40)
        tempLabel.textAlignment = NSTextAlignment.center
        return tempLabel
    }()
    
    lazy var recordLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.textAlignment = NSTextAlignment.center
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 25)
        return tempLabel
    }()
    
    lazy var currentLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.textAlignment = NSTextAlignment.center
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 20)
        return tempLabel
    }()
    //================================================================================
    // MARK:- life cycle
    //================================================================================
    init(cacheKey: String, backColor: UIColor) {
        self.cacheKey = cacheKey
        super.init(frame: .zero)
        self.backgroundColor = backColor
        self.addSubview(backBtn)
        backBtn.center = CGPoint(x: 80, y: 220)
        backBtn.bounds = CGRect(x: 0, y: 0, width: 80, height: 40)
        
        self.addSubview(startBtn)
        startBtn.center = CGPoint(x: 200, y: 220)
        startBtn.bounds = CGRect(x: 0, y: 0, width: 80, height: 40)
        
        self.addSubview(titleLabel)
        titleLabel.center = CGPoint(x: 150, y: 80)
        titleLabel.bounds = CGRect(x: 0, y: 0, width: 300, height: 100)
        
        self.addSubview(recordLabel)
        recordLabel.center = CGPoint(x: 150, y: 120)
        recordLabel.bounds = CGRect(x: 0, y: 0, width: 300, height: 40)
        
        self.addSubview(currentLabel)
        currentLabel.center = CGPoint(x: 150, y: 160)
        currentLabel.bounds = CGRect(x: 0, y: 0, width: 300, height: 40)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //================================================================================
    // MARK:- public method
    //================================================================================
    
    func show(_ supView:UIView,score:Int){
    
        currentLabel.text = "当前分数 --- \(score)"
        cacheRecord(score: score)
        let score = self.highestScore()
        recordLabel.text = "最高记录 --- \(score)"
        
        supView.addSubview(self)
        self.center = CGPoint(x: supView.center.x, y: supView.center.y - 50)
        self.bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
        self.layer.cornerRadius = 30
        self.transform = transform.scaledBy(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func hide(){
        self.removeFromSuperview()
    }
    
    //================================================================================
    // MARK:- pravite methods
    //================================================================================
    fileprivate func cacheRecord(score:Int) {
        
        if let tempScore = UserDefaults.standard.object(forKey: cacheKey) {
            let oldScore = tempScore as! Int
            if score > oldScore {
                UserDefaults.standard.set(score, forKey: cacheKey)
            }
        }else{
             UserDefaults.standard.set(score, forKey: cacheKey)
        }
    
    }
    
    fileprivate func highestScore() -> Int{
        if let tempScore = UserDefaults.standard.object(forKey: cacheKey) {
            return tempScore as! Int
        }
        return 0
    }
    
    
    //================================================================================
    // MARK:- target action
    //================================================================================
    @objc fileprivate func restartBtn(){
        self.delegte?.noticeViewChoseRestart()
    }
    
    @objc fileprivate func onBack() {
        self.delegte?.onBack()
    }
}
