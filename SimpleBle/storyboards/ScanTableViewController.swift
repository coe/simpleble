//
//  ScanTableViewController.swift
//  SimpleBle
//
//  Created by tsuyoshi hyuga on 2018/04/19.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanTableViewController: UITableViewController,ScanDataSourceDelegate {
    func scanDataSourceDidChange(_ dataSource: ScanDataSource) {
        tableView.reloadData()
    }
    

    var scanDataSource:ScanDataSource!

    var centralManager:CBCentralManager!

    var longDataServiceUuid:CBUUID!

    private var _selectedScannedPeripheral:CBPeripheral?
    var selectedScannedPeripheral:CBPeripheral? {
        get {
            return _selectedScannedPeripheral
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scanDataSource.delegate = self
        centralManager.scanForPeripherals(withServices: [longDataServiceUuid], options: nil)
    }
    
    deinit {
        centralManager.stopScan()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanDataSource.tableView(tableView,numberOfRowsInSection:section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return scanDataSource.tableView(tableView,cellForRowAt:indexPath)
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = scanDataSource.getPeripheral(indexPath: indexPath)
        _selectedScannedPeripheral = data
        performSegue(withIdentifier: "backToConnection", sender: self)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
