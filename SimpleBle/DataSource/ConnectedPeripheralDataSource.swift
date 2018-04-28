//
//  ConnectedPeripheralDataSource.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/04/28.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreData

class ConnectedPeripheralDataSource: NSObject {
    
    var fetchedResultsController: NSFetchedResultsController<ConnectedPeripheral>!
    
    init(managedObjectContext:NSManagedObjectContext,delegate:NSFetchedResultsControllerDelegate) {
        super.init()

        let request = NSFetchRequest<ConnectedPeripheral>(entityName: "ConnectedPeripheral")
        let lastNameSort = NSSortDescriptor(key: "create_at", ascending: true)
        request.sortDescriptors = [lastNameSort]

        let fetchedResultsController = NSFetchedResultsController<ConnectedPeripheral>(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        self.fetchedResultsController = fetchedResultsController
        fetchedResultsController.delegate = delegate
    }
}

extension ConnectedPeripheralDataSource : UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedPeripheralCell", for: indexPath)
        let data = fetchedResultsController.object(at: indexPath)

        cell.textLabel?.text = data.name
//        cell.detailTextLabel?.text = data.identifier?.uuidString
        
        return cell
    }
    
    
}
