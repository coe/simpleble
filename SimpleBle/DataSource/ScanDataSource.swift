//
//  ScanDataSource.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/04/30.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ScanDataSourceDelegate : class {
    func scanDataSourceDidChange(_ dataSource:ScanDataSource)
}

class ScanDataSource: NSObject {
    
    weak var delegate:ScanDataSourceDelegate?
    
    var scannedPeripheral:[CBPeripheral] = []
    
    func append(_ device:CBPeripheral) {
        scannedPeripheral.append(device)
        self.delegate?.scanDataSourceDidChange(self)
    }
    
    func clear() {
        scannedPeripheral.removeAll()
        self.delegate?.scanDataSourceDidChange(self)
    }
    
    func getPeripheral(indexPath: IndexPath) -> CBPeripheral {
        return scannedPeripheral[indexPath.row]
    }
}

extension ScanDataSource : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedPeripheral.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanDeviceDataSourceCell", for: indexPath)
        let peripheral = scannedPeripheral[indexPath.row]
        
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    
}
