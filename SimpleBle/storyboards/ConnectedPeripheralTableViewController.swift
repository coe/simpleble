//
//  ConnectedPeripheralTableViewController.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/04/28.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth


/// 書き込みの流れ
/// 1.長さを書き込む
/// 2.writeレスポンス
/// 3.データ書き込み
class ConnectedPeripheralTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    private var connectedPeripheralDataSource:ConnectedPeripheralDataSource!
    
    var centralManager:CBCentralManager!
    var peripheralManager:CBPeripheralManager!
    var managedObjectContext:NSManagedObjectContext!
    
    var appDelegate:AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectedPeripheralDataSource = ConnectedPeripheralDataSource(managedObjectContext: managedObjectContext, delegate: self)
        //TODO:常に電波はだしておく
        let uuid = CBUUID(string: SERVICE_UUID)
        
        let option:[String : Any] = [
            CBAdvertisementDataServiceUUIDsKey:[uuid],
            CBAdvertisementDataLocalNameKey:"na"
        ]
        peripheralManager.startAdvertising(option)
    }
    
    deinit {
        peripheralManager.stopAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return connectedPeripheralDataSource.numberOfSections(in:tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedPeripheralDataSource.tableView(tableView,numberOfRowsInSection:section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return connectedPeripheralDataSource.tableView(tableView,cellForRowAt:indexPath)

    }
    
    var dataLength = 0
    var dataBytes:Data? = nil

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = connectedPeripheralDataSource.getPeripheral(cellForRowAt: indexPath)
        peripheral.services?.forEach({ (service) in
            service.characteristics?.forEach({ (characteristic) in
                switch characteristic.uuid {
                case CBUUID(string: BIGDATA_LENGTH_CHARACTERISTIC_UUID):
                    
                    break
                default:
                    break
                }
            })
        })
    }
    
    // MARK : - IBAction
    @IBAction func onClickTest(_ sender: Any) {
        let entity = NSEntityDescription.entity(forEntityName: "ConnectedPeripheral", in: managedObjectContext)
        let data = ConnectedPeripheral(entity: entity!, insertInto: managedObjectContext)
        let uuid = UUID()
        print("uuid:\(uuid.uuidString)")

        data.identifier = uuid
        data.name = "test"
        data.create_at = Date()
        appDelegate.saveContext()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        tableView.reloadData()
    }
    
    @IBAction func backToTop(segue: UIStoryboardSegue,sender:Any?) {
        let scanTableViewController:ScanTableViewController = segue.source as! ScanTableViewController
        
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showScan":
                let viewController:ScanTableViewController = segue.destination as! ScanTableViewController
                viewController.managedObjectContext = managedObjectContext
                viewController.centralManager = centralManager
                break
            default:
                break
            }
        }
    }

}
