//
//  ListViewController.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 28/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    var list: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.dataSource = self
        self.listTableView.delegate = self
    
        self.listTableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "itensFromList",
            let itemController = segue.destination as? ItemViewController {
            itemController.list = self.list!
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    @IBAction func addListBarBtnTapped(_ sender: Any) {
        let newListAlert = UIAlertController(title: "List name", message: "Please, enter your new list name", preferredStyle: .alert)
        
        newListAlert.addTextField { (newListTextField) in
            newListTextField.placeholder = "List name"
        }
        let saveAction = UIAlertAction(title: "Create", style: .default) { (action:UIAlertAction) in
            let listName = newListAlert.textFields?.first?.text!
            
            //Save Core Data
            self.list = CDManager.saveList(name: listName!)
            //Save CloudKit
            var listCK = List(withName: listName!)
            CKManager.save(record: listCK.ckRecord(), inDB: CKManager.privateDB, completion: { (record) in
            //...
            })
            
            print(self.list!.name!)
            self.listTableView.reloadData()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        newListAlert.addAction(cancelAction)
        newListAlert.addAction(saveAction)

        self.present(newListAlert, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CDManager.getLists()!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: "listCell") as! UITableViewCell
        guard let lists = CDManager.getLists() else { return cell }
        let list = lists[indexPath.row]
        cell.textLabel!.text = list.name
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.list = CDManager.getLists()![indexPath.row]
        performSegue(withIdentifier: "itensFromList", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let list = CDManager.getLists()![indexPath.row]
            
            //Delete from Core Data
            CDManager.deleteList(list: list)
            //Delete from Cloudkit
            if let listRecord = list.ckRecord() {
                CKManager.delete(record: listRecord, inDB: CKManager.privateDB, completion: { (result) in
                    //...
                })
            }
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, indexPath) in
            //
        }
        delete.backgroundColor = .red
        share.backgroundColor = .blue
        return [delete, share]
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            let list = self.CDManager.getLists()![indexPath.row]
//            self.CDManager.deleteList(list: list)
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }
}
