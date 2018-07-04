//
//  SnakeBody.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import Foundation
import UIKit

protocol SnakeMoveDelegate: class {
    func snakeDidMove2Frame(rect: CGRect)
}

class SnakeBody: NSObject {
    weak var delegate: SnakeMoveDelegate?
    private var side: CGPoint = .zero
    private var isMoving: Bool = false
    private var backView: UIView!
    private var nodeWidth: CGFloat = 20
    private var nodes: [SnakeNode] = []
    private var link: CADisplayLink?
    
    init(backView: UIView) {
        self.backView = backView
        super.init()
        prepareBody()
        link = CADisplayLink(target: self, selector: #selector(moveForward))
        link?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func startMoving() {
        isMoving = true
    }
    
    func stopMoving() {
        isMoving = false
    }
    
    func prepareBody() {
        for node in nodes {
            node.removeFromSuperview()
        }
        nodes.removeAll()
        side = CGPoint(x: 0, y: 1)
        eatFoodCount(count: 10)
    }
    
    func eatFoodCount(count: Int) {
        for _ in 0..<count {
            var p: CGPoint = CGPoint(x: 200, y: 100)
            if let node = nodes.first {
                p = node.center
            }
            let node = SnakeNode(frame: CGRect(x: 0.0, y: 0.0, width: nodeWidth, height: nodeWidth))
            p.x += (side.x * nodeWidth/10);
            p.y += (side.y * nodeWidth/10);
            node.setCenter(p)
            backView.addSubview(node)
            nodes.insert(node, at: 0)
        }
    }
    
    @objc func moveForward() {
        if (!isMoving) {
            return
        }
        eatFoodCount(count: 1)
        nodes.last?.removeFromSuperview()
        nodes.removeLast()
        if let first = nodes.first {
            self.delegate?.snakeDidMove2Frame(rect: first.frame)
        }
    }
    
    func setSide(side: CGPoint) {
        let s = sqrt(side.x * side.x + side.y*side.y)
        if s > 0.001 {
            self.side = CGPoint(x: side.x/s, y: side.y/s)
        }
    }
}
