//
//  AssistiveConstant.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/29.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

let screenFrame = UIScreen.main.bounds
let screenWidth = screenFrame.size.width
let screenHeight = screenFrame.size.height

let assistiveWidth: CGFloat = 60.0

let animationDuration: TimeInterval = 0.5

let cornerRadius: CGFloat = assistiveWidth / 2

var contentViewSpreadFrame: CGRect {
    let spreadWidth = screenFrame.width * 0.64
    let frame = CGRect(x: (screenFrame.width - spreadWidth)/2 , y: (screenFrame.height - spreadWidth)/2, width: spreadWidth, height: spreadWidth)
    return frame
}

var defaultPoint: CGPoint {
    let x = screenWidth - assistiveWidth
    let y = screenHeight - assistiveWidth - 49
    return CGPoint(x: x, y: y)
}
