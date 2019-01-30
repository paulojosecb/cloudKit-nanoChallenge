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
        CDManager.saveList(name: listName) { (listSaved) in
            //Save CloudKit
            if let list = listSaved {
                CKManager.save(record: list.ckRecord(), inDB: CKManager.privateDB, completion: { (record) in
                    //...
                })
            } else { print("error on saving CK")}
        }
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
        //Save Core Data
        CDManager.saveItem(to: list, name: name) { (itemSaved) in
            //Save CloudKit
            if let item = itemSaved {
                //Save to Cloudkit
                CKManager.save(item: item, inList: list, completion: { (record) in
                    //...
                })
            } else { print("error on saving CK")}
        }
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
