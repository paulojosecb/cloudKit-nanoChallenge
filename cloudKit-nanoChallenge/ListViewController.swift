//
//  ListViewController.swift
//  cloudKit-nanoChallenge
//
//  Created by Amanda Tavares on 28/01/19.
//  Copyright © 2019 Paulo José. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    var list: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.dataSource = self
        self.listTableView.delegate = self
    
        self.listTableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "itensFromList",
            let itemController = segue.destination.children.first as? ItemViewController, let itemIndex = listTableView.indexPathForSelectedRow?.row
        {
            print("segue ok")
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
            print(listName!)
            self.list.append(listName!)
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
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: "listCell") as! UITableViewCell
        cell.textLabel!.text = self.list[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let indexPath = listTableView.indexPathForSelectedRow
        //let currentCell = tableView.cellForRow(at: indexPath!) as! UITableViewCell
        
        performSegue(withIdentifier: "itensFromList", sender: self)
    }
}
