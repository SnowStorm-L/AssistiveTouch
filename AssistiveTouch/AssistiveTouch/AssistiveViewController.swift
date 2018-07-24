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
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.rowHeight = 80
        tableView.layer.cornerRadius = contentCornerRadius
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return tableView
    }()
    
    var dataSource = [0, 1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAndSetupDefaultUI()
        createAndSetupCustomUI()
        createAndAddGesture()
    }
    
    func moveContentView(toPoint point: CGPoint) {
        contentCenterPoint = point
    }
    
    //MARK: - Original setting
    
    private var isShowed = false
    
    private let contentCornerRadius: CGFloat = 10.0
    
    private var contentCenterPoint = CGPoint.zero {
        didSet {
            guard !isShowed else { return }
            contentView.center = contentCenterPoint
        }
    }
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.center = contentCenterPoint
        contentView.layer.cornerRadius = contentCornerRadius
        contentView.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        return contentView
    }()
    
    private lazy var shrinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        imageView.image = UIImage(named: "uploadFloating")
        return imageView
    }()
    
}

private extension AssistiveViewController {
    
    //MARK: - UI
    
    func createAndSetupDefaultUI() {
        view.addSubview(contentView)
        view.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
        contentView.addSubview(shrinkImageView)
    }
    
    func createAndSetupCustomUI()  {
        contentView.addSubview(tableView)
    }
    
    func createAndAddGesture() {
        let tapToExpandGesture = UITapGestureRecognizer(target: self, action: #selector(expandAction))
        let tapToShrinkGesture = UITapGestureRecognizer(target: self, action: #selector(shrinkAction))
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction(_:)))
        dragGesture.delegate = self
        contentView.addGestureRecognizer(dragGesture)
        contentView.addGestureRecognizer(tapToExpandGesture)
        view.addGestureRecognizer(tapToShrinkGesture)
    }
    
    //MARK: - Animate And State
    
    func setExpandUIState() {
        
        shrinkImageView.isHidden = true
        
        // Custom UI State
        tableView.isHidden = false
        
        UIView.animate(withDuration: animationDuration) {
            self.contentView.frame = contentViewSpreadFrame
            self.contentView.backgroundColor = UIColor(hue: 0.1, saturation: 0, brightness: 0.1, alpha: 0.1)
            // Custom UI Animate
            self.tableView.frame = self.contentView.bounds
        }
        
    }
    
    func setShrinkUIState() {
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentView.frame = CGRect(x: 0, y: 0, width: assistiveWidth, height: assistiveWidth)
            self.contentView.center = self.contentCenterPoint
            // Custom UI Animate
            self.tableView.frame = self.contentView.bounds
        }) { _ in
            self.delegate?.assistiveViewController(self, actionEndAtPoint: self.contentCenterPoint)
            self.shrinkImageView.isHidden = false
            self.contentView.backgroundColor = .clear
            // Custom UI State
            self.tableView.isHidden = true
        }
        
    }
    
}

// MARK: - Action
@objc private extension AssistiveViewController {
    
    func expandAction() {
        
        if isShowed { return }
        
        delegate?.assistiveViewController(self, actionBeginAtPoint: contentCenterPoint)
        
        isShowed = true
        
        setExpandUIState()
    }
    
    func shrinkAction() {
        
        if !isShowed { return }
        
        isShowed = false
        
        setShrinkUIState()
    }
    
    func dragAction(_ dragGesture: UIPanGestureRecognizer) {
        
        if isShowed { return }
        
        let point = dragGesture.location(in: view)
        
        var pointOffset = CGPoint(x: cornerRadius, y: cornerRadius)
        
        var isNeedRecordPoint = false
        
        if isNeedRecordPoint {
            pointOffset = dragGesture.location(in: contentView)
        }
        
        if dragGesture.state == .began {
            
            delegate?.assistiveViewController(self, actionBeginAtPoint: contentCenterPoint)
            
        } else if dragGesture.state == .changed {
            
            contentCenterPoint = CGPoint(x: point.x + cornerRadius - pointOffset.x, y: point.y  + cornerRadius - pointOffset.y)
            
        } else if [.cancelled, .failed, .ended].contains(dragGesture.state) {
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.contentCenterPoint = self.stickToPointByHorizontal()
            }, completion: { _ in
                self.delegate?.assistiveViewController(self, actionEndAtPoint: self.contentCenterPoint)
                isNeedRecordPoint = true
            })
            
        }
        
    }
    
}


// MARK: - Util
private extension AssistiveViewController {
    
    func stickToPointByHorizontal() -> CGPoint {
        let center = contentCenterPoint
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

// MARK: - UITableView

/// UIGestureRecognizerDelegate
extension AssistiveViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isShowed
    }
}


/// UITableViewDataSource, UITableViewDelegate
extension AssistiveViewController: UITableViewDataSource & UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = "\(dataSource[indexPath.row])"
        cell.textLabel?.textColor = .cyan
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            clearWhiteBackgroundWhenDelete()
        }
    }
    
    func clearWhiteBackgroundWhenDelete() {
        if let whiteBackgroudViewClass = NSClassFromString("_UISwipeToDeletePlaceholderCell") {
           _ = tableView.subviews.map { if $0.isKind(of: whiteBackgroudViewClass) { $0.backgroundColor = .clear } }
        }
    }
    
}

