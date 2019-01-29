//
//  ItemViewController.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 28/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var itemTableView: UITableView!
    var itens: [String] = []
    @IBOutlet weak var itensTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemTableView.dataSource = self
        self.itemTableView.delegate = self
        
        
    }
    @IBAction func backToListBtn(_ sender: Any) {
      // not working
        // _ = navigationController?.popViewController(animated: true)

    }
    @IBAction func addItemBarBtnTapped(_ sender: Any) {
        let newItemAlert = UIAlertController(title: "Item name", message: "Please, enter your new item name", preferredStyle: .alert)
        
        newItemAlert.addTextField { (newItemTextField) in
            newItemTextField.placeholder = "Item name"
        }
        let saveAction = UIAlertAction(title: "Create", style: .default) { (action:UIAlertAction) in
            let itemName = newItemAlert.textFields?.first?.text!
            print(itemName!)
            self.itens.append(itemName!)
            self.itensTableView.reloadData()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        newItemAlert.addAction(cancelAction)
        newItemAlert.addAction(saveAction)
        
        self.present(newItemAlert, animated: true, completion: nil)
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "itemCell")!
        cell.textLabel?.text = self.itens[indexPath.row]
        return cell
    }
    
}
