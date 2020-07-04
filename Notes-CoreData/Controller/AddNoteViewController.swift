//
//  AddNoteViewController.swift
//  Notes-CoreData
//
//  Created by Sailor on 03/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {

    var category : Category!
    var notes : Notes!
    var editSave : Bool!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editSave{
           //button item
           let buttonSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addNotes))
           navigationItem.rightBarButtonItem = buttonSave
        }else{
            //button item
            let buttonEdit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNotes))
            navigationItem.rightBarButtonItem = buttonEdit
            titleTextField.text = notes.title
            textView.text = notes.text
        }
       
    }
    
    @objc func addNotes(){
        let context = ManagerConnection().context()
        let entityNotes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context) as! Notes
        
        entityNotes.id = UUID()
        entityNotes.id_category = category.id
        entityNotes.title = titleTextField.text
        entityNotes.text = textView.text
        entityNotes.date = Date()
        
        category.mutableSetValue(forKey: "relationToNotes").add(entityNotes)
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true) //save and comeback
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    @objc func editNotes(){
        let context = ManagerConnection().context()
        
        notes.setValue(titleTextField.text, forKey: "title")
        notes.setValue(textView.text, forKey: "text")
        notes.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true) //save and comeback
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

   

}
