//
//  Item.swift
//  cloudKit-nanoChallenge
//
//  Created by Débora Oliveira on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class Item: CKManagedObject {
    var recordName: String?
    var recordID: Data?
    var lastUpdate: Data?
    
    var name : String
    
    init(witName name: String) {
        self.name = name
        self.createCKRecord()
    }
    
    required init(from record: CKRecord) {
        self.name = record.value(forKey: "name") as! String
        self.recordName = record.recordID.recordName
        let recordID = record.recordID
        self.recordID = self.ckRecordIDToData(recordID)
    }
    
    func ckRecord(_ completion: @escaping ((CKRecord) -> Void)) {
        guard let recordType = self.recordType else { return }
        
        var record = CKRecord(recordType: recordType, recordID: self.ckRecordID())
        
        CKManager.fetchRecordById(self.ckRecordID()) { (result) in
            if let result = result {
                record = result
            }
            record["name"] = self.name as CKRecordValue
            //            record["user"] = self.user as CKRecordValue
            completion(record)
        }
    }
    
    func createCKRecord() {
        guard let recordType = recordType else { return }
        
        let uuid = UUID()
        self.recordName = recordType + "." + uuid.uuidString
        let _recordID = CKRecord.ID(recordName: recordName!)
        recordID = ckRecordIDToData(_recordID)
    }
}
