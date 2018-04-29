//
//  ScanTableViewController.swift
//  SimpleBle
//
//  Created by tsuyoshi hyuga on 2018/04/19.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

/// スキャンの結果を表示する
/// この画面が終了したらスキャンは消滅させる
///
class ScanTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {

    private var scanDeviceDataSource:ScanDeviceDataSource!
    
    var centralManager:CBCentralManager!

    private var _selectedScannedPeripheral:ScannedPeripheral?
    var selectedScannedPeripheral:ScannedPeripheral? {
        get {
            return _selectedScannedPeripheral
        }
    }
    var managedObjectContext:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        scanDeviceDataSource = ScanDeviceDataSource(managedObjectContext: managedObjectContext, delegate: self)
        let uuid = CBUUID(string: SERVICE_UUID)
        centralManager.scanForPeripherals(withServices: [uuid], options: nil)
    }
    
    deinit {
        centralManager.stopScan()
        let request = NSFetchRequest<NSManagedObject>(entityName: "ScannedPeripheral")
        do {
            let ret = try managedObjectContext.fetch(request)
            ret.forEach { (movie) in
                managedObjectContext.delete(movie)
            }
            try managedObjectContext.save()
        } catch {
            print(#file,#function,#line,"error:\(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanDeviceDataSource.tableView(tableView,numberOfRowsInSection:section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return scanDeviceDataSource.tableView(tableView,cellForRowAt:indexPath)
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = scanDeviceDataSource.fetchedResultsController.object(at: indexPath)
        _selectedScannedPeripheral = data
        performSegue(withIdentifier: "backToConnection", sender: self)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        tableView.reloadData()
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
