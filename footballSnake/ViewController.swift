//
//  ViewController.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var footballs: [UIImageView] = []
    private var balls: [UIImage] = [#imageLiteral(resourceName: "football1"), #imageLiteral(resourceName: "football2"), #imageLiteral(resourceName: "football3"), #imageLiteral(resourceName: "football4"), #imageLiteral(resourceName: "football5"), #imageLiteral(resourceName: "football6"), #imageLiteral(resourceName: "football7"), #imageLiteral(resourceName: "football8"), #imageLiteral(resourceName: "football9")]
    private var snakeBody = SnakeBody(backView: UIView())
    private var stakeView = StakeView(frame: CGRect(x: UIScreen.main.bounds.width - 150, y: UIScreen.main.bounds.height - 150, width: 100, height: 100))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIScreen.main.bounds.height)
        prepareFootballs()
        stakeView.delegate = self
        snakeBody = SnakeBody(backView: view)
        snakeBody.delegate = self
        view.backgroundColor = UIColor.white
        scoreLabel.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height == 812 ? 50 : 24, width: 40, height: 25)
        startPauseBtn.frame = CGRect(x: UIScreen.main.bounds.width/2 - 93, y: UIScreen.main.bounds.height - 112, width: 48, height: 48)
        startPauseBtn.addTarget(self, action: #selector(starOrPausetGame), for: .touchUpInside)
        view.addSubview(stakeView)
        view.addSubview(scoreLabel)
        view.addSubview(startPauseBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
    }
    
    func setScore(_ score: Int) {
        scoreLabel.text = "\(score)"
    }
    
    @objc func starOrPausetGame() {  // 开始和暂停
        if !startPauseBtn.isSelected {
            snakeBody.startMoving()
            startPauseBtn.isSelected  = true
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
        let alert = UIAlertController(title: "游戏结束", message: "您的得分是 \(score)", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "重新开始", style: .default) { [weak self] (action) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.starOrPausetGame()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel , handler: nil)
        alert.addAction(restartAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        prepareFootballs()
    }

}

extension ViewController: StakeDelegate {
    func stakeDidChange(_ offset: CGPoint) {
        if offset.x == 0 && offset.y == 0 {
            return
        }
        snakeBody.setSide(side: offset)
    }
}

extension ViewController: SnakeMoveDelegate {
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
