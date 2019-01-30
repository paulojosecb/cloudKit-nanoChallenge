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
        return CKContainer(identifier: "iCloud.com.paulocardosob.cloudKit-nanoChallenge-Amanda")

    }
    
    var customZone: CKRecordZone?
    static var privateDB = CKManager.container.privateCloudDatabase
    static var publicDB = CKManager.container.publicCloudDatabase
    static var sharedDB = CKManager.container.sharedCloudDatabase
    
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
    
    static func save(record: CKRecord?, inDB database: CKDatabase, completion: @escaping ((CKRecord?) -> Void)) {
        guard let record = record else { return }
        
        database.save(record) { (saved, error) in
            guard let saved = saved, error == nil else {
                print("ERROR! CKManager: Could not save records. \(error!.localizedDescription)")
                return
            }
            completion(saved)
        }
    }
    
    static func save(item: Item, inList list : List, completion: @escaping ((CKRecord?) -> Void)) {
        guard let itemRecord = item.ckRecord() else { return }
        guard let listRecord = list.ckRecord() else { return }
        
        let parentReference = CKRecord.Reference(record: listRecord, action: .deleteSelf)
        itemRecord.setValue(parentReference, forKey: "list")
        
        CKManager.publicDB.save(itemRecord) { (saved, error) in
            guard let saved = saved, error == nil else {
                print("ERROR! CKManager: Could not save item. \(error!.localizedDescription)")
                return
            }
            completion(saved)
        }
    }
    
    //Pode ser alterado pra ser mais genérico
    static func delete(record: CKRecord, inDB database: CKDatabase, completion: @escaping ((Bool) -> Void)) {
        database.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
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
    
//    static func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
//        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
//        publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            guard let records = records, error == nil else {
//                completion(nil, error)
//                return
//            }
//
//            let users = records.map({ (record) -> User in
//                let user = User(from: record)
//                return user
//            })
//
//            completion(users, nil)
//        }
//
//    }
//
//
//    static func fetchUser(token: String, completion: @escaping (CKRecord?, User?, Error?) -> Void) {
//        let predicate = NSPredicate(format: "token = %@", token)
//        let query = CKQuery(recordType: "User", predicate: predicate)
//
//        publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            guard let record = records?.first else {
//                completion(nil, nil, error)
//                return
//            }
//
//            let user = User(from: record)
//            completion(record, user, nil)
//        }
//    }
//
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
        guard let userRecord = user.ckRecord() else { return }
        self.save(record: userRecord, inDB: publicDB) { (recordSaved) in
            //...
        }
    }
    
    // Retorna o usuário logado atualmente
    static func getUser(then completion: @escaping ((User) -> Void)) {
        container.fetchUserRecordID { (recordID, error) in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            self.discoverIdentity(for: recordID, then: { (user) in
                self.publicDB.fetch(withRecordID: recordID, completionHandler: { (userRecord, error) in
                    guard let userRecord = userRecord, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    completion(user)
                })
            })
        }
    }
    
    //Pega o nome e email do usuário logado
    static private func discoverIdentity(for recordID: CKRecord.ID, then completion: @escaping ((User) -> Void)) {
        self.container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            guard status == .granted, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            self.container.discoverUserIdentity(withUserRecordID: recordID) { (identity, error) in
                guard let identity = identity, let components = identity.nameComponents, error == nil else {
                    return
                }
                
                let fullName = PersonNameComponentsFormatter().string(from: components)
                let email = identity.lookupInfo?.emailAddress
                
                completion(User(withName: fullName))
            }
        }
    }
    
    
    static func checkStatus(_ completion: @escaping ((Bool) -> Void)) {
        self.container.accountStatus { (status, error) in
            switch status {
            case .available:
                completion(true)
            case .couldNotDetermine, .noAccount, .restricted:
                completion(false)
            }
        }
//        CKContainer.default().accountStatus { (status, error) in
//            if error != nil {
//                print("Deu ruim")
//            } else {
//                switch status {
//                case .available:
////                    self.iCloudUserID(completion: { (recordID, error) in
////                        guard let recordID = recordID, error == nil else {
////                            return
////                        }
////                    })
//                case .couldNotDetermine, .noAccount, .restricted:
//                   return
//
//                }
//            }
//        }
    }
    
   
    

    
    
}
