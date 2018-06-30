//
//  AssistiveTouch.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/29.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

// 这个类是单例调用,所持有属性(window, controller)是不释放的
// 如果是单个页面使用,不使用单例, 外面控制器,实例化,持有 直接用 就可以释放

class AssistiveTouch: NSObject {
    
    static let share = AssistiveTouch()
    
    var isShow = false
    
    var assistiveWindow: UIWindow?
    
    var assistiveViewController: AssistiveViewController?
    
    var assistiveWindowPoint = defaultPoint
    
    override init() {
        super.init()
        assistiveViewController = AssistiveViewController()
        assistiveViewController?.delegate = self
    }
    
    func makeVisibleWindow() {
        assistiveWindow?.makeKeyAndVisible()
        UIApplication.shared.keyWindow?.makeKey()
    }
    
    func showAssistiveTouch() {
        if isShow { return }
        assistiveWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth))
        assistiveWindow?.windowLevel = .greatestFiniteMagnitude
        setlocation()
        assistiveWindow?.layer.masksToBounds = true
        assistiveWindow?.rootViewController = assistiveViewController
        makeVisibleWindow()
        isShow = true
    }
    
    func closeAssistiveTouch() {
        assistiveWindow?.rootViewController = nil
        assistiveWindow?.removeFromSuperview()
        assistiveWindow?.resignKey()
        assistiveWindow = nil
        isShow = false
    }
    
    func setlocation() {
        let rect = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        assistiveWindow?.frame = rect
        assistiveWindow?.center = assistiveWindowPoint
    }

}

extension AssistiveTouch: AssistiveViewControllerDelegate  {
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionBeginAtPoint point: CGPoint) {
        assistiveWindow?.frame = screenFrame
        assistiveViewController?.view.frame = screenFrame
        assistiveViewController?.moveContentView(toPoint: assistiveWindowPoint)
    }
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionEndAtPoint point: CGPoint) {
        assistiveWindowPoint = point
        setlocation()
        let contentPoint = CGPoint(x: cornerRadius, y: cornerRadius)
        assistiveViewController?.moveContentView(toPoint: contentPoint)
    }
    
}
