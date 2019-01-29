//
//  Manager.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class Manager {
    //let localRepository: CDManager!
    //let remoteRepository: CKManager!
    fileprivate var listsToSave = [List]()
    fileprivate var listsToDelete = [List]()
    
    init() {
    }
    
    static func save(list listName: String) {
        //Save Core Data
        CDManager.saveList(name: listName)
        //Save CloudKit
        let listCK = List(withName: listName)
        CKManager.save(record: listCK.ckRecord(), inDB: CKManager.privateDB, completion: { (record) in
            //...
        })
    }
    
    static func delete(list: List) {
        //Delete from Core Data
        CDManager.deleteList(list: list)
        //Delete from Cloudkit
        if let listRecord = list.ckRecord() {
            CKManager.delete(record: listRecord, inDB: CKManager.privateDB, completion: { (result) in
                //...
            })
        }
    }
    
    static func save(item name: String, to list: List) {
        //Save to Core Data
        CDManager.saveItem(to: list, name: name)
        //Save to Cloudkit
        let itemCK = Item(withName: name)
        CKManager.save(record: itemCK.ckRecord(), inDB: CKManager.publicDB, completion: { (record) in
            //...
        })
    }
    
    static func delete(item: Item) {
        //Delete from Core Data
        CDManager.deleteItem(item: item)
        //Delete From Cloudkit
        if let itemRecord = item.ckRecord() {
            CKManager.delete(record: itemRecord, inDB: CKManager.publicDB, completion: { (result) in
                //...
            })
        }
        
    }
}
