//
//  SnakeNode.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import Foundation
import UIKit

class SnakeNode: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCenter(_ center: CGPoint) {
        self.center = center
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        self.backgroundColor = UIColor(red: center.x/width, green: 1-center.x/width, blue: center.y/height, alpha: 1)
    }
}
