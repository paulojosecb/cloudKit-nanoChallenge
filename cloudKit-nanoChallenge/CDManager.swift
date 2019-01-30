//
//  CoreDataManager.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 29/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CoreData

// Singleton to handle and manage core data
class CDManager: NSObject {
    
    static var context : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static public func saveList(name: String, completion: @escaping ((List?) -> Void)) {
        do {
            let list = List(withName: name)
            
            try context.save()
            
            completion(list)

        } catch let error {
            completion(nil)
            print(error.localizedDescription)
        }
    }
    
    static public func getLists() -> [List]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        do {
            let lists = try CDManager.context.fetch(request) as! [List]
            return lists
        }
        catch {
            fatalError("Failed to fetch: \(error)")
        }
    }
    
    static public func getList(by name: String) -> List {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let lists = try CDManager.context.fetch(request) as! [List]
            let list = lists.first
            return list!
        }
        catch {
            fatalError("Failed to fetch: \(error)")
        }
    }

    static public func editList(name: String){
        let list = getList(by: name)
        list.setValuesForKeys(["name" : name])
        
        try? CDManager.context.save()
    }
    
    static public func deleteList(list: List){
        CDManager.context.delete(list)
        try? CDManager.context.save()
    }
    
    static public func saveItem(to list: List, name: String, completion: @escaping ((Item?) -> Void)) {
        do {
            let item = Item(withName: name)
            list.addToItens(item)
        
            try context.save()
            
            completion(item)
            
        } catch let error {
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    static public func getItens(from list: List) -> [Item]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        //request.fetchLimit = 1
        request.predicate = NSPredicate(format: "list == %@", list)
        
        do {
            let itens = try CDManager.context.fetch(request) as! [Item]
            return itens
        }
        catch let error {
            fatalError("Failed to fetch: \(error)")
        }
    }
    
    static public func deleteItem(item: Item){
        CDManager.context.delete(item)
        try? CDManager.context.save()
    }
    
    static public func dropListDatabase(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.includesPropertyValues = false
        
        do {
            let items = try CDManager.context.fetch(request) as! [NSManagedObject]
            
            for item in items {
                CDManager.context.delete(item)
            }
            
            // Save Changes
            try CDManager.context.save()
            
        } catch {
            fatalError("Failed to drop: \(error)")
        }
    }
}
