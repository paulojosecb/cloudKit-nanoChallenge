//
//  ItemViewController.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 28/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UIViewController {

    @IBOutlet weak var itemTableView: UITableView!
    var itens: [Item]?
    var list: List!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemTableView.dataSource = self
        self.itemTableView.delegate = self
        
        self.navigationItem.title = "\(list.name!) Itens"

    }
    override func viewWillAppear(_ animated: Bool) {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "itemCell")!
        cell.textLabel?.text = ""
    }
    
    @IBAction func addItemBarBtnTapped(_ sender: Any) {
        let newItemAlert = UIAlertController(title: "Item name", message: "Please, enter your new item name", preferredStyle: .alert)
        
        newItemAlert.addTextField { (newItemTextField) in
            newItemTextField.placeholder = "Item name"
        }
        let saveAction = UIAlertAction(title: "Create", style: .default) { (action:UIAlertAction) in
            if let itemName = newItemAlert.textFields?.first?.text {
                Manager.save(item: itemName, to: self.list)
            }
            
            self.itemTableView.reloadData()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        newItemAlert.addAction(cancelAction)
        newItemAlert.addAction(saveAction)
        
        self.present(newItemAlert, animated: true, completion: nil)
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return CDManager.getItens(from: list)!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "itemCell")!
        if let itens = CDManager.getItens(from: list) {
            cell.textLabel!.text = itens[indexPath.row].name
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let item = CDManager.getItens(from: self.list)![indexPath.row]
            
            Manager.delete(item: item)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
