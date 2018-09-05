//
//  CoreDataHandler.swift
//  ZohoContacts
//
//  Created by Administrator on 19/06/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler: NSObject {

    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(uid:String,firstName:String,lastName:String,phoneNo:String,found:String) -> Bool{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ContactData", in: context)
//        let et2 = NSEntityDescription.entity(forEntityName: "GroupContactRelation", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
//        let mo = NSManagedObject(entity: et2!, insertInto: context)

        managedObject.setValue(uid, forKey: "uid")
        managedObject.setValue(firstName, forKey: "firstName")
        managedObject.setValue(lastName, forKey: "lastName")
        managedObject.setValue(phoneNo, forKey: "phoneNo")
        managedObject.setValue(found, forKey: "found")

        do{
            try context.save()
            return true
        } catch {
            return false
        }
        
    }
    
    class func setFound(uid:String,found:String) -> Bool {
        
        let context = getContext()
        let fetchRequest:NSFetchRequest = ContactData.fetchRequest()
        var contactData:[ContactData]? = nil
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchRequest.predicate = predicate
        
        do{
            contactData = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        contactData?.first?.setValue(found, forKey: "found")
        do{
            try context.save()
            return true
        } catch {
            return false
        }
        
    }
    
    class func fetchObject() -> [ContactData]? {
        
        let context = getContext()
        var contactData:[ContactData]? = nil
        do{
            contactData = try context.fetch(ContactData.fetchRequest())
            return contactData
        } catch {
            return contactData
        }
        
    }
    
    class func deleteObject(person:ContactData) -> Bool {
        
        let context = getContext()
        context.delete(person)
        
        do{
            try context.save()
            return true
        } catch {
            return false
        }
        
    }
    
    class func cleanDelete() -> Bool {
        
        let context = getContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: ContactData.fetchRequest())
        
        do {
            try context.execute(deleteRequest)
            print("Contacts clean deleted")
            return true
        } catch {
            return false
        }
        
    }
    
    class func filterData(uid:String) -> [ContactData]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<ContactData> = ContactData.fetchRequest()
        var contactData:[ContactData]? = nil
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchRequest.predicate = predicate
        
        do{
            contactData = try context.fetch(fetchRequest)
            return contactData
        } catch {
            return contactData
        }
        
    }
    
    
}




















