//
//  StakeView.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import Foundation
import UIKit

protocol StakeDelegate: class {
    func stakeDidChange(_ offset: CGPoint) -> Void
}

class StakeView: UIView {
    weak var delegate: StakeDelegate?
    var diameter: CGFloat = 0   //直径
    var orgCenter: CGPoint = .zero    //初始位置
    var offset: CGPoint = .zero
    var tipView: UIView = UIView()
    
    override init(frame: CGRect) {
        diameter = frame.size.width > frame.size.height ? frame.size.height : frame.size.width;
        var newFrame = frame
        newFrame.size.width = diameter
        newFrame.size.height = self.diameter;
        super.init(frame: newFrame)
        isUserInteractionEnabled = true;
        orgCenter = self.center;
        layer.cornerRadius = diameter/2;
        backgroundColor = UIColor.lightGray
        tipView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.diameter/3, height: self.diameter/3))
            view.backgroundColor = UIColor.darkGray
            view.layer.cornerRadius = diameter/6
            return view
        }()
        addSubview(tipView)
        setOffset(offset: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setOffset(offset: CGPoint) {
        if (offset.x.isNaN || offset.y.isNaN) {
            return;
        }
        self.offset = offset;
        self.tipView.center = CGPoint(x: offset.x * diameter/2 + diameter/2, y: offset.y*diameter/2 + diameter/2);
        self.delegate?.stakeDidChange(offset);
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            var p: CGPoint = t.location(in: self)
            //计算相对于中心点的位置
            p.x-=(diameter/2)
            p.y-=(diameter/2)
            //直线距离
            let s: CGFloat = sqrt(p.x*p.x+p.y*p.y)
            //与半径的倍数
            let ts: CGFloat = s/(diameter/2)
            if (ts > 1) {
                p.x /= ts
                p.y /= ts
            }
            p.x/=(self.diameter/2)
            p.y/=(self.diameter/2)
            self.setOffset(offset: p)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.center = orgCenter
        setOffset(offset: .zero)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.center = orgCenter
        setOffset(offset: .zero)
    }
}
