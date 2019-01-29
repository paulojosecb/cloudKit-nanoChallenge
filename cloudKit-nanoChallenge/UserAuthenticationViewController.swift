//
//  UserAuthenticationViewController.swift
//  cloudKit-nanoChallenge
//
//  Created by Thalia Freitas on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CloudKit

class UserAuthenticationViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createUser(with: "Thalia")
       
        
    }
    
    
    var container = CKContainer(identifier: "iCloud.com.thalia.CloudKit-Study")
    
    var publicDatabase = CKContainer(identifier: "iCloud.com.thalia.CloudKit-Study").publicCloudDatabase

    func iCloudUserID(completion: @escaping (String?, Error?) -> Void) {
        
        container.fetchUserRecordID() { recordID, error in
            
            guard let recordID = recordID, error == nil else {
                completion(nil, error)
                return
            }
            
            completion(recordID.recordName, nil)
        }
    }
    
    
    
    func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            guard let records = records, error == nil else {
                completion(nil, error)
                return
            }
            
            let users = records.map({ (record) -> User in
                let user = User(record: record)
                return user
            })
            
            completion(users, nil)
        }
        
    }
    
    
        

//    func fetchUser(token: String, completion: @escaping (CKRecord?, User?, Error?) -> Void) {
//
//        let predicate = NSPredicate(format: "token = %@", token)
//
//        let query = CKQuery(recordType: "User", predicate: predicate)
//
//        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
//
//            guard let record = records?.first else {
//                completion(nil, nil, error)
//                return
//            }
//
//            let user = User(record: record)
//            completion(record, user, nil)
//        }
//
//    }
    
    func fetchUser(id: CKRecord.ID, completion: @escaping (CKRecord?, User?, Error?) -> Void) {
        
        let predicate = NSPredicate(format: "recordID = %@", id)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            guard let record = records?.first else {
                completion(nil, nil, error)
                return
            }
            
            let user = User(record: record)
            completion(record, user, nil)
        }
        
    }
    

    
    
    func createUser(with name: String) {
        
        let user = User(name: name)
        self.save(record: user.record, InDataBase: publicDatabase)
    }
    
    
    func save(record: CKRecord, InDataBase dataBase: CKDatabase){
        dataBase.save(record) { (record, error) -> Void in
            guard let record = record else {
                print("Error saving record: ", error?.localizedDescription)
                return
            }
            print("Successfully saved record", record)
        }
    }
    

}
