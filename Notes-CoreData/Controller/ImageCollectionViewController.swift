//
//  ImageCollectionViewController.swift
//  Notes-CoreData
//
//  Created by Sailor on 04/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import UIKit
import CoreData


class ImageCollectionViewController: UICollectionViewController {

    var imageNote = [Images]()
    var notes : Notes!
    var photo : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = notes.title
        
        let buttonCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto))
               navigationItem.rightBarButtonItem = buttonCamera
        
        // configure collectionview, 3 columns
        let imageSize = UIScreen.main.bounds.width / 3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 1, bottom: 10, right: 1)
        layout.itemSize = CGSize(width: imageSize, height: imageSize)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        collectionView.collectionViewLayout = layout
        
        viewImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewImage()
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageNote.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        let imageNoteItem = imageNote[indexPath.row]
        if let image = imageNoteItem.image{
            cell.photo.image = UIImage(data: image as Data)
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewPhoto", sender: indexPath)
    }
    
    @objc func addPhoto(){
        let alert = UIAlertController(title: "Take photo", message: "Camera / Galery", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Take photo", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let galery = UIAlertAction(title: "Enter galery", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .currentContext
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(galery)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto"{
            let id = sender as! NSIndexPath
            let row = imageNote[id.row]
            let destiny = segue.destination as! ViewPhotoViewController
            destiny.imageNote = row
        }
    }
    
    
    
    func viewImage(){
        let context = ManagerConnection().context()
        
        let fetchRequest : NSFetchRequest<Images> = Images.fetchRequest()
        let id = notes.id
        fetchRequest.predicate = NSPredicate(format: "id_notes == %@", id! as CVarArg)
        
        
        do {
            imageNote = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}

extension ImageCollectionViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) //
        let imageTake = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        photo = imageTake
        
        let context = ManagerConnection().context()
        let entityImage = NSEntityDescription.insertNewObject(forEntityName: "Images", into: context) as! Images
        
        entityImage.id = UUID()
        entityImage.id_notes = notes.id
        //cast for data
        let imageFinal = photo.pngData()
        entityImage.image = imageFinal
        
        notes.mutableSetValue(forKey: "relationToImages").add(entityImage)
        
        do {
            try context.save()
            self.viewImage()
            self.collectionView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageCollectionViewController: UINavigationControllerDelegate{
    
}
