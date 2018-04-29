//
//  ScanDeviceDataSource.swift
//  SimpleBle
//
//  Created by tsuyoshi hyuga on 2018/04/19.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class ScanDeviceDataSource: NSObject {
    
    var peripherals:[CBPeripheral] = []

    var fetchedResultsController: NSFetchedResultsController<ScannedPeripheral>!
    
    init(managedObjectContext:NSManagedObjectContext,delegate:NSFetchedResultsControllerDelegate) {
        super.init()
        
        let request = NSFetchRequest<ScannedPeripheral>(entityName: "ScannedPeripheral")
        let lastNameSort = NSSortDescriptor(key: "create_at", ascending: true)
        request.sortDescriptors = [lastNameSort]
        
        let fetchedResultsController = NSFetchedResultsController<ScannedPeripheral>(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        self.fetchedResultsController = fetchedResultsController
        fetchedResultsController.delegate = delegate
    }
    
    func getPeripheral(cellForRowAt indexPath: IndexPath) -> CBPeripheral {
        return peripherals[indexPath.row]
    }
}


extension ScanDeviceDataSource : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = fetchedResultsController.fetchedObjects?.count,count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanDeviceDataSourceCell", for: indexPath)
        let data = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = data.name
        //        cell.detailTextLabel?.text = data.identifier?.uuidString
        
        return cell
    }
    
    
}
