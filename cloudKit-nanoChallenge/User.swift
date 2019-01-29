//
//  User.swift
//  cloudKit-nanoChallenge
//
//  Created by Thalia Freitas on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CloudKit

class User {
    
    var record: CKRecord
    
    var id: CKRecord.ID? {
        get {
            return record.recordID
        }
    }
    
    var name: String {
        set {
            record["name"] = newValue
        }
        get {
            return record["name"] as! String
        }
    }
    
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init(name: String) {
        record = CKRecord(recordType: "User")
        self.name = name
        
    }


}
