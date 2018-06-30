//
//  ViewController.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/29.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        AssistiveTouch.share.showAssistiveTouch()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        AssistiveTouch.share.closeAssistiveTouch()
        self.navigationController?.pushViewController(SecondViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

