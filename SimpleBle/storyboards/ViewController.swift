//
//  ViewController.swift
//  SimpleBle
//
//  Created by tsuyoshi hyuga on 2018/04/19.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickPeripheral(_ sender: Any) {
        
    }
    
    @IBAction func backToTop(segue: UIStoryboardSegue,sender:Any?) {
        if let controller = segue.source as? ScanTableViewController {
            print("controller.retValue:\(controller.retValue)")
            
        }
    }
    
}

