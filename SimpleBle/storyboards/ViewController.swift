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

    var centralManager:CBCentralManager!
    var peripheralManager:CBPeripheralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickPeripheral(_ sender: Any) {
        //電波だす
        if !peripheralManager.isAdvertising {
            print("電波だす")
            let uuid = CBUUID(string: SERVICE_UUID)
            
            let option:[String : Any] = [
                CBAdvertisementDataServiceUUIDsKey:[uuid],
                CBAdvertisementDataLocalNameKey:"na"
            ]
            peripheralManager.startAdvertising(option)
        } else {
            print("電波ださない")
            peripheralManager.stopAdvertising()
        }
        
    }

}

