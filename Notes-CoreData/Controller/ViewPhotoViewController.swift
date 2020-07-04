//
//  ViewPhotoViewController.swift
//  Notes-CoreData
//
//  Created by Sailor on 04/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import UIKit
import CoreData

class ViewPhotoViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    var imageNote : Images!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            if let image = imageNote.image{
                photo.image = UIImage(data: image as Data)
            }
        
        let buttonTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhoto))
                     navigationItem.rightBarButtonItem = buttonTrash
    }
    

    @objc func deletePhoto(){
        let context = ManagerConnection().context()
        let fetchRequest : NSFetchRequest<Images> = Images.fetchRequest()
        
        let id = imageNote.id
        fetchRequest.predicate = NSPredicate(format: "id == %@", id! as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            for res in result{
                context.delete(res)
            }
            try context.save()
            
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

}
