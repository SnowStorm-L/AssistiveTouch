//
//  AssistiveViewController.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/29.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

protocol AssistiveViewControllerDelegate: class {
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionBeginAtPoint point: CGPoint)
    
    func assistiveViewController(_ viewController: AssistiveViewController, actionEndAtPoint point: CGPoint)
    
}

class AssistiveViewController: UIViewController {
    
    weak var delegate: AssistiveViewControllerDelegate?
    
    private var isShowed = false
    
    private var contentPoint = CGPoint(x: cornerRadius, y: cornerRadius) {
        willSet {
            if !isShowed {
                contentView.center = newValue
            }
        }
    }
    
    lazy var shrinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        imageView.isHidden = false
        imageView.image = UIImage(named: "uploadFloating")
        return imageView
    }()
    
    lazy var uploadTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.rowHeight = 80
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .clear
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return tableView
    }()
    
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.center = contentPoint
        contentView.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        return contentView
    }()
    
    lazy var spreadGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(spread))
    
    lazy var shrinkGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shrink))
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pan.delegate = self
        return pan
    }()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(contentView)
        view.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        contentView.addSubview(shrinkImageView)
        //contentView.addSubview(uploadTableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addGestureRecognizer(panGestureRecognizer)
        contentView.addGestureRecognizer(spreadGestureRecognizer)
        view.addGestureRecognizer(shrinkGestureRecognizer)
    }
    
    func moveContentView(toPoint point: CGPoint) {
        contentPoint = point
    }
    
    func invokeActionBeginDelegate() {
        if !isShowed {
            delegate?.assistiveViewController(self, actionBeginAtPoint: contentPoint)
        }
    }
    
    func invokeActionEndDelegate() {
        delegate?.assistiveViewController(self, actionEndAtPoint: contentPoint)
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension AssistiveViewController: UIGestureRecognizerDelegate {
    
    //    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if let touchClass = gestureRecognizer.view?.classForCoder {
    //            return NSStringFromClass(touchClass) != "UITableViewCellContentView"
    //        }
    //        return true
    //    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension AssistiveViewController: UITableViewDataSource & UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}


// MARK: - Action
@objc extension AssistiveViewController {
    
    func spread() {
        
        if isShowed { return }
        invokeActionBeginDelegate()
        uploadTableView.isHidden = false
        isShowed = !isShowed
        shrinkImageView.isHidden = true
        
        UIView.animate(withDuration: animationDuration) {
            self.contentView.frame = contentViewSpreadFrame
            self.uploadTableView.frame = self.contentView.bounds
            self.contentView.backgroundColor = UIColor(hue: 0.1, saturation: 0, brightness: 0.1, alpha: 0.1)
        }
        
    }
    
    func shrink() {
        if !isShowed { return }
        isShowed = !isShowed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.uploadTableView.isHidden = true
        }
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentView.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
            self.contentView.center = self.contentPoint
            self.uploadTableView.frame = self.contentView.bounds
        }) { _ in
            self.invokeActionEndDelegate()
            self.shrinkImageView.isHidden = false
            self.contentView.backgroundColor = .clear
        }
    }
    
    func pan(_ pan: UIPanGestureRecognizer) {
        
        if isShowed { return }
        
        let point = pan.location(in: view)
        var pointOffset = CGPoint(x: cornerRadius, y: cornerRadius)
        var isNeedRecordPoint = false
        if isNeedRecordPoint {
            pointOffset = pan.location(in: contentView)
        }
        
        if pan.state == .began {
            invokeActionBeginDelegate()
        } else if pan.state == .changed {
            contentPoint = CGPoint(x: point.x + cornerRadius - pointOffset.x, y: point.y  + cornerRadius - pointOffset.y)
        } else if [.cancelled, .failed, .ended].contains(pan.state) {
            UIView.animate(withDuration: animationDuration, animations: {
                self.contentPoint = self.stickToPointByHorizontal()
            }) { _ in
                self.invokeActionEndDelegate()
                isNeedRecordPoint = true
            }
        }
        
    }
    
}


// MARK: - Util
extension AssistiveViewController {
    
    func stickToPointByHorizontal() -> CGPoint {
        let center = contentPoint
        if center.y < center.x && center.y < -center.x + screenWidth {
            var point = CGPoint(x: center.x, y: cornerRadius)
            point = makePointValid(point: &point)
            return point
        } else if center.y > center.x + screenHeight - screenWidth
            && center.y > -center.x + screenHeight {
            var point = CGPoint(x: center.x, y: screenHeight - cornerRadius)
            point = makePointValid(point: &point)
            return point
        } else {
            if center.x < screenWidth / 2 {
                var point = CGPoint(x: cornerRadius, y: center.y)
                point = makePointValid(point: &point)
                return point
            } else {
                var point = CGPoint(x: screenWidth - cornerRadius, y: center.y)
                point = makePointValid(point: &point)
                return point
            }
        }
    }
    
    func makePointValid(point: inout CGPoint) -> CGPoint {
        if point.x < cornerRadius {
            point.x = cornerRadius
        }
        if point.x > screenWidth - cornerRadius {
            point.x = screenWidth - cornerRadius
        }
        if point.y < cornerRadius {
            point.y = cornerRadius
        }
        if point.y > screenHeight - cornerRadius {
            point.y = screenHeight - cornerRadius
        }
        return point
    }
    
}
