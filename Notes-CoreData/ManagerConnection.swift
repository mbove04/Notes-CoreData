//
//  ManagerConnection.swift
//  Notes-CoreData
//
//  Created by Sailor on 03/07/2020.
//  Copyright © 2020 com.sailor. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ManagerConnection{
    
    func context()-> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
}
