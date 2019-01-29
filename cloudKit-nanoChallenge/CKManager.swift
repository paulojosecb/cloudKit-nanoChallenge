//
//  CloudKitManager.swift
//  cloudKit-nanoChallenge
//
//  Created by Débora Oliveira on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class CKManager {

    private static var container : CKContainer {
        return CKContainer(identifier: "iCloud.com.thalia.CloudKit-Study")
    }
    
    var customZone: CKRecordZone?
    private static var privateDB = CKManager.container.privateCloudDatabase
    private static var publicDB = CKManager.container.publicCloudDatabase
    private static var sharedDB = CKManager.container.sharedCloudDatabase
    
    init() {
        self.customZone = CKRecordZone(zoneName: "NOME DA ZONA CUSTOMIZADA")
    }
    
    //Pode ser alterado para selecionar o banco (private, public, shared)
    static func fetchRecordById(_ id: CKRecord.ID, completion: @escaping ((CKRecord?) -> Void)) {
        self.publicDB.fetch(withRecordID: id, completionHandler: { (record, error) in
            guard let record = record, error == nil else {
                print("ERROR! CKManager: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            completion(record)
        })
    }
    
    //Pode ser feito um "fetch all" que pega todos de um RecordType
    static func fetchAllLists(of user: User, completion: @escaping (([List]) -> Void)) {
        let userReference = CKRecord.Reference(recordID: user.ckRecordID(), action: .none)
        
        let query = CKQuery(recordType: "Lists", predicate: NSPredicate(format: "user == %@", userReference))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            guard error == nil else {
                print("ERROR! CKManager: Could not find records. \(error!.localizedDescription)")
                return
            }
            var lists = [List]()
            
            records?.forEach({ (record) in
                lists.append(List(from: record))
            })
            completion(lists)
        })
    }
    
    static func fetchAllItems(from list: List, completion: @escaping (([Item]) -> Void)) {
        let listReference = CKRecord.Reference(recordID: list.ckRecordID(), action: .none)
        
        let query = CKQuery(recordType: "Item", predicate: NSPredicate(format: "list == %@", listReference))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            guard error == nil else {
                print("ERROR! CKManager: Could not find records. \(error!.localizedDescription)")
                return
            }
            var items = [Item]()
            
            records?.forEach({ (record) in
                items.append(Item(from: record))
            })
            completion(items)
        })
    }
    
    //Pode ser alterado pra ser mais genérico
    static func save(list: List, completion: @escaping ((List) -> Void)) {
        list.ckRecord { (listRecord) in
            self.publicDB.save(listRecord) { (saved, error) in
                guard let saved = saved, error == nil else {
                    print("ERROR! CKManager: Could not save records. \(error!.localizedDescription)")
                    return
                }
                
                let updatedList = List(from: saved)
                completion(updatedList)
            }
        }
    }
    
    //Pode ser alterado pra ser mais genérico
    static func delete(list: List, completion: @escaping ((Bool) -> Void)) {
        CKManager.container.publicCloudDatabase.delete(withRecordID: list.ckRecordID(), completionHandler: { (recordID, error) in
            guard error == nil else {
                print("ERROR! CKManager: Could not delete records. \(error!.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
// a partir daqui código da thalia
    
    
    static func iCloudUserID(completion: @escaping (String?, Error?) -> Void) {
        
        container.fetchUserRecordID() { recordID, error in
            
            guard let recordID = recordID, error == nil else {
                completion(nil, error)
                return
            }
            
            completion(recordID.recordName, nil)
        }
    }
    
    
    
    static func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            guard let records = records, error == nil else {
                completion(nil, error)
                return
            }
            
            let users = records.map({ (record) -> User in
                let user = User(from: record)
                return user
            })
            
            completion(users, nil)
        }
        
    }
    
    
    
    
    static func fetchUser(token: String, completion: @escaping (CKRecord?, User?, Error?) -> Void) {
        
        let predicate = NSPredicate(format: "token = %@", token)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            guard let record = records?.first else {
                completion(nil, nil, error)
                return
            }
            
            let user = User(from: record)
            completion(record, user, nil)
        }
        
    }
    
    static func fetchUser(id: CKRecord.ID, completion: @escaping (CKRecord?, User?, Error?) -> Void) {
        
        let predicate = NSPredicate(format: "recordID = %@", id)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            guard let record = records?.first else {
                completion(nil, nil, error)
                return
            }
            
            let user = User(from: record)
            completion(record, user, nil)
        }
        
    }
    
    
    static func createUser(withName name: String) {
        
        let user = User(withName: name)
        
        user.ckRecord { (record) in
            self.save(record: record, InDataBase: publicDB)
        }
        
    }
    
    
    static func save(record: CKRecord, InDataBase dataBase: CKDatabase){
        dataBase.save(record) { (record, error) -> Void in
            guard let record = record else {
                print("Error saving record: ", error?.localizedDescription)
                return
            }
            print("Successfully saved record", record)
        }
    }
    
    
    
}
