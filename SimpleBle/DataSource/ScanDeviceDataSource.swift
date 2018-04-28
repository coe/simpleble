//
//  ScanDeviceDataSource.swift
//  SimpleBle
//
//  Created by tsuyoshi hyuga on 2018/04/19.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanDeviceDataSource: NSObject,UITableViewDataSource,CBCentralManagerDelegate {
    
    var manager:CBCentralManager!
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            let uuid:CBUUID = CBUUID(string: SERVICE_UUID)
            manager.scanForPeripherals(withServices: [uuid], options: nil)
            
            break
            
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        }
    }
    
    
    override init() {
        super.init()
        //スキャン
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    //MARK: - CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "aaaa"
        cell.detailTextLabel?.text = "bbbb"
        return cell
    }
    
    
}
