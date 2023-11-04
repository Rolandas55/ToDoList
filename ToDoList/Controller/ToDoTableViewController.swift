//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by kraujalis.rolandas on 30/10/2023.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext?
    var toDos: [String] = []
    var toDoLists = [ToDoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "To Do List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { titleField in
            titleField.placeholder = "Your title here..."
        }
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your item here..."
            print(textFieldValue)
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let titleField = alertController.textFields?.first
            let textField = alertController.textFields?.last
            let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(titleField?.text, forKey: "title")
            list.setValue(textField?.text, forKey: "item")
            self.saveCoreData()
            //            self.toDos.append(textField!.text!)
            //            self.tableView.reloadData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        
        present(alertController, animated: true)
    }
    
    @IBAction func deleteAllItemsTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete", message: "everything from To Do list will be deleted", preferredStyle: .alert)
        let addActionButton = UIAlertAction(title: "OK", style: .default) { addAction in
            self.deleteAllCoreData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isEditing = true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - CoreData logic
extension ToDoTableViewController {
    func loadCoreData() {
        let request: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        let sort = NSSortDescriptor(key: "orderIndex", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let result = try managedObjectContext?.fetch(request)
            toDoLists = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading item from core data")
        }
    }
    func saveCoreData() {
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
    func deleteAllCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "ToDoList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(deleteRequest)
        } catch {
            fatalError("Error in deleting Items")
        }
        saveCoreData()
    }
}

// MARK: - Table view data source
extension ToDoTableViewController {
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return toDos.count
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        
        let toDoList = toDoLists[indexPath.row]
        cell.textLabel?.text = toDoLists[indexPath.row].title
        cell.detailTextLabel?.text = toDoLists[indexPath.row].item
        cell.accessoryType = toDoList.completed ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveCoreData()
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
             managedObjectContext?.delete(toDoLists[indexPath.row])
         }
         saveCoreData()
     }

     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         toDoLists.swapAt(fromIndexPath.row, to.row)
         for(index, cell) in toDoLists.enumerated() {
             cell.orderIndex = Int32(index)
         }
         saveCoreData()
     }
    
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
