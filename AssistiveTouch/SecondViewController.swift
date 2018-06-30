//
//  SecondViewController.swift
//  AssistiveTouch
//
//  Created by L on 2018/6/30.
//  Copyright © 2018年 L. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    let a = AssistiveTouch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        a.showAssistiveTouch()
        self.view.backgroundColor = .red
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        a.closeAssistiveTouch()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
