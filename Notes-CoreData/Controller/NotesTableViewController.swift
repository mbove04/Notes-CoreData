//
//  NotesTableViewController.swift
//  Notes-CoreData
//
//  Created by Sailor on 03/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {

    var notes = [Notes]()
    var fetchResultController : NSFetchedResultsController<Notes>!
    var category : Category!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title
        self.title = category.name
        
        //button item
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotes))
        navigationItem.rightBarButtonItem = buttonAdd
        
        viewNotes()
    }
    
    @objc func addNotes(){
        performSegue(withIdentifier: "addNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNote"{
            let destiny = segue.destination as! AddNoteViewController
            destiny.category = category
            destiny.editSave =  true
        }
        
        if segue.identifier == "editNote"{
            if let id = tableView.indexPathForSelectedRow{
                let row = notes[id.row]
                let destiny = segue.destination as! AddNoteViewController
                destiny.notes = row
                destiny.editSave = false
            }
        }
        
        if segue.identifier == "goToPhoto"{
             let id = sender as! NSIndexPath
             let row = notes[id.row]
             let destiny = segue.destination as! ImageCollectionViewController
             destiny.notes = row
           
        }
    }

    //NSFETCHCONTROLLER
    func viewNotes(){
         let context = ManagerConnection().context()
         let fetchRequest : NSFetchRequest<Notes> = Notes.fetchRequest()
         //order by name where id_category = 'id_cat'
         let orderByName = NSSortDescriptor(key: "title", ascending: true)
         fetchRequest.sortDescriptors = [orderByName]
         
         let id_cat = category.id
        //where
         fetchRequest.predicate = NSPredicate(format: "id_category == %@", id_cat! as CVarArg)
        
         fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
         
         fetchResultController.delegate = self
         
         do {
             try fetchResultController.performFetch()
             notes = fetchResultController.fetchedObjects!
         } catch let error as NSError {
             print(error.localizedDescription)
         }
     }
    
   
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        let formatDate = DateFormatter()
        //formatDate.dateStyle = .full
        // formatDate.dateFormat = "dd-MM-yyyy"
        formatDate.dateFormat = "MMM dd,yyyy"
        let date = formatDate.string(from: note.date!)
        cell.detailTextLabel?.text = date
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
        
        let camera = UITableViewRowAction(style: .normal, title: "Photo ") { (_, indexPath) in
            self.performSegue(withIdentifier: "goToPhoto", sender: indexPath)
        }
        
        return [delete,camera]
    }

   
}

extension NotesTableViewController: NSFetchedResultsControllerDelegate{
    // all methods FetchResultController
       func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.beginUpdates() //update tableview
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.endUpdates() // update tableview
       }
       
       //didchange, animations
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           
           switch type {
           case .insert:
               self.tableView.insertRows(at: [newIndexPath!], with: .fade)
           case .delete:
               self.tableView.deleteRows(at: [indexPath!], with: .fade)
           case .update:
               self.tableView.reloadRows(at: [indexPath!], with: .fade)
           default:
               self.tableView.reloadData()
           }
           
           self.notes = controller.fetchedObjects as! [Notes]
       }
       
}
