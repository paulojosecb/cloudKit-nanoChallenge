//
//  List.swift
//  cloudKit-nanoChallenge
//
//  Created by Débora Oliveira on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension List: CKManagedObject {
    
    convenience init(withName name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "List", in: CDManager.context)!
        self.init(entity: entity, insertInto: CDManager.context)
        
        self.recordType =  "List"
        self.name = name
        self.createCKRecord()
    }
    
    convenience init(from record: CKRecord) {
        let entity = NSEntityDescription.entity(forEntityName: "List", in: CDManager.context)!
        self.init(entity: entity, insertInto: CDManager.context)
        
        self.name = record.value(forKey: "name") as! String
        self.recordName = record.recordID.recordName
        self.recordType =  "List"
        let recordID = record.recordID
        self.recordID = self.ckRecordIDToData(recordID)
    }
    
    func ckRecord() -> CKRecord? {
        guard let recordType = self.recordType, let name = self.name else { return nil }
        
        let record = CKRecord(recordType: recordType, recordID: self.ckRecordID())
        record["name"] = name as CKRecordValue
        
        return record
    }
    
    func createCKRecord() {
        guard let recordType = recordType else { return }
        
        let uuid = UUID()
        self.recordName = recordType + "." + uuid.uuidString
        let _recordID = CKRecord.ID(recordName: recordName!)
        recordID = ckRecordIDToData(_recordID)
    }
}
