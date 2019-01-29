//
//  CKManagedObject.swift
//  cloudKit-nanoChallenge
//
//  Created by Débora Oliveira on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

protocol CKManagedObject {
    var recordName: String? { get set }
    var recordID: Data? { get set }
    var lastUpdate: Data? { get set }
    
    func ckRecord(_ completion: @escaping ((CKRecord) -> Void))
    func createCKRecord()
}

extension CKManagedObject {
    
    var recordType: String? {
        get {
            return recordTypeFrom(recordName: self.recordName)
        }
    }
    
    func ckRecordID() -> CKRecord.ID {
        let obj = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self.recordID!)
        return obj as! CKRecord.ID
    }
    
    func ckRecordIDToData(_ recordID: CKRecord.ID) -> Data {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: recordID, requiringSecureCoding: true)
        } catch let error {
            fatalError("ERROR! CKManagedObject: Cannot convert recordID to Data: \(error.localizedDescription)")
        }
    }
    
    private func recordTypeFrom(recordName: String?) -> String? {
        guard let index = recordName?.firstIndex(of: ".") else {
            fatalError("ERROR! RecordID.recordName does not contain an entity prefix")
        }
        guard let recordType = recordName?[..<index] else { return nil }
        
        return String(recordType)
        
    }
    
}
