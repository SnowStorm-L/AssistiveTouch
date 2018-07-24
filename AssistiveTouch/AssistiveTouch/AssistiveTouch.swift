//
//  AssistiveTouch.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/29.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

class AssistiveTouch {
    
    static let share = AssistiveTouch()
    
    private var assistiveWindow: UIWindow?
    
    var assistiveViewController: AssistiveViewController?
    
    private var windowCenterPoint = defaultPoint
 
    func showAssistiveTouch() {
        if assistiveWindow != nil {
            return
        }
        createWindow()
        createController()
        makeVisibleWindow()
    }
    
    func closeAssistiveTouch() {
        assistiveWindow?.rootViewController = nil
        assistiveWindow?.removeFromSuperview()
        assistiveWindow?.resignKey()
        assistiveWindow = nil
    }
    
}

private extension AssistiveTouch {
    
    func createWindow() {
        assistiveWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth))
        setWindowlocation()
        assistiveWindow?.layer.masksToBounds = true
        createController()
    }
    
    func createController() {
        if assistiveViewController == nil {
            assistiveViewController = AssistiveViewController()
        }
        assistiveViewController?.delegate = self
        assistiveWindow?.rootViewController = assistiveViewController
    }
    
    func setWindowlocation() {
        let rect = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        assistiveWindow?.frame = rect
        assistiveWindow?.center = windowCenterPoint
    }
    
    func makeVisibleWindow() {
        // 如果新的window界面和app的原始window界面都要弹窗的话
        // 一定要确定好弹出的controller
        let window = UIApplication.shared.keyWindow
        assistiveWindow?.makeKeyAndVisible()
        window?.makeKey()
    }
    
}

extension AssistiveTouch: AssistiveViewControllerDelegate  {
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionBeginAtPoint point: CGPoint) {
        assistiveWindow?.frame = screenFrame
        viewController.view.frame = screenFrame
        viewController.moveContentView(toPoint: windowCenterPoint)
    }
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionEndAtPoint point: CGPoint) {
        windowCenterPoint = point
        setWindowlocation()
        let contentPoint = CGPoint(x: cornerRadius, y: cornerRadius)
        viewController.moveContentView(toPoint: contentPoint)
    }
    
}
