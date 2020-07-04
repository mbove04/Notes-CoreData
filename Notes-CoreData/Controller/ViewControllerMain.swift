//
//  ViewController.swift
//  Notes-CoreData
//
//  Created by Sailor on 03/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerMain: UIViewController {
 
    
    @IBOutlet weak var tableViewOut: UITableView!
    
    
    var categorys = [Category]()
    
    var fetchResultController: NSFetchedResultsController<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        viewCategory()
    }
 
    
    
    func viewCategory(){
        let context = ManagerConnection().context()
        let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
        //order by name
        let orderByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [orderByName]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            categorys = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Category", message: "Enter name for category ", preferredStyle: .alert)
        //add textfield in alert
        alert.addTextField { (name) in
            name.placeholder = "Name for category"
        }
        let accept = UIAlertAction(title: "Accept", style: .default) { (action) in
            guard let name = alert.textFields?.first?.text else {return}
            let context = ManagerConnection().context()
            
            let entityCategory = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as! Category
            
            entityCategory.id = UUID()
            entityCategory.name = name
            
            do{
                try context.save()
            } catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(accept)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
}

extension ViewControllerMain: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOut.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categorys[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNotes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNotes"{
            if let id = tableViewOut.indexPathForSelectedRow{
                let row = categorys[id.row]
                let destiny = segue.destination as! NotesTableViewController
                destiny.category = row
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
        let context = ManagerConnection().context()
        let delete =  self.fetchResultController.object(at: indexPath)
        context.delete(delete)
           
           do{
               try context.save()
           }catch let error as NSError{
               print(error.localizedDescription)
           }
       }
       
       return [delete]
    }
    
    
}

extension ViewControllerMain: NSFetchedResultsControllerDelegate{
    
    // all methods FetchResultController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewOut.beginUpdates() //update tableview
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewOut.endUpdates() // update tableview
    }
    
    //didchange, animations
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableViewOut.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableViewOut.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableViewOut.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tableViewOut.reloadData()
        }
        
        self.categorys = controller.fetchedObjects as! [Category]
    }
    
}

