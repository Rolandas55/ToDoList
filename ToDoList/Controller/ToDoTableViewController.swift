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
    var toDoLists = [ToDoList]()
    private var cellID = "toDoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        setupView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addNewItem() {
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
                }
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
                alertController.addAction(addActionButton)
                alertController.addAction(cancelActionButton)
        
                present(alertController, animated: true)
    }
    
    @objc func deleteAllItems() {
        let alertController = UIAlertController(title: "Delete", message: "everything from To Do list will be deleted", preferredStyle: .alert)
        let addActionButton = UIAlertAction(title: "OK", style: .default) { addAction in
            self.deleteAllCoreData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    
    @objc func togglEditMode() {
        tableView.isEditing.toggle()
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        let detailViewController = DetailViewController()
        if sender.state == UIGestureRecognizer.State.began {
            let touchPath = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPath) {
                print(indexPath)
                navigationController?.pushViewController(detailViewController, animated: true)
                if let string = toDoLists[indexPath.row].title {
                    detailViewController.toDoTitle = string
                }
                if let string = toDoLists[indexPath.row].item {
                    detailViewController.toDoSubtitle = string
                }
                detailViewController.todoCompleted = toDoLists[indexPath.row].completed
                //basicActionSheet(title: toDoLists[indexPath.row].item, message: "Completed: \(toDoLists[indexPath.row].completed)")
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let addBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewItem))
        let deleteBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteAllItems))
        let editBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square"), style: .done, target: self, action: #selector(togglEditMode))
        self.navigationItem.rightBarButtonItems = [addBarButtonItem, editBarButtonItem]
        self.navigationItem.leftBarButtonItem = deleteBarButtonItem
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longPressRecognizer)
        
        setupNavigationBarView()
    }
    
    private func setupNavigationBarView() {
        title = "To Do"
        let titleImage = UIImage(systemName: "bag.badge.plus")
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "GillSans", size: 18)
        
        messageLabel.textColor = UIColor.secondaryLabel
        messageLabel.font = UIFont(name: "GillSans", size: 16)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: 20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
    }
    
    func restoreTableViewStyle() {
        self.backgroundView = nil
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
    
    func basicActionSheet(title: String?, message: String?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.overrideUserInterfaceStyle = .dark
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
}

// MARK: - Table view data source
extension ToDoTableViewController {
//        override func numberOfSections(in tableView: UITableView) -> Int {
//            // #warning Incomplete implementation, return the number of sections
//            return toDos.count
//        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoLists.count == 0 {
            tableView.setEmptyView(title: "Your To Do is Empty", message: "Please press Add to create a new to do item")
        } else {
            tableView.restoreTableViewStyle()
        }
        return toDoLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
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
