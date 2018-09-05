//
//  GroupCoreDataHandler.swift
//  ZohoContacts
//
//  Created by Administrator on 25/06/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import CoreData

class GroupCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(guid:String,groupName:String) -> Bool{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "GroupsData", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(guid, forKey: "guid")
        managedObject.setValue(groupName, forKey: "groupName")
        
        do{
            try context.save()
            return true
        } catch {
            return false
        }
        
    }
    
    class func setFound(uid:String,found:String) -> Bool {
        
        let context = getContext()
        let fetchRequest:NSFetchRequest = GroupsData.fetchRequest()
        var contactData:[GroupsData]? = nil
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
    
    class func fetchObject() -> [GroupsData]? {
        
        let context = getContext()
        var contactData:[GroupsData]? = nil
        do{
            contactData = try context.fetch(GroupsData.fetchRequest())
            return contactData
        } catch {
            return contactData
        }
        
    }
    
    class func deleteObject(person:GroupsData) -> Bool {
        
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
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: GroupsData.fetchRequest())
        
        do {
            try context.execute(deleteRequest)
            print("Groups clean deleted")
            return true
        } catch {
            return false
        }
        
    }
    
    class func filterData(gname:String) -> [GroupsData]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<GroupsData> = GroupsData.fetchRequest()
        var contactData:[GroupsData]? = nil
        let predicate = NSPredicate(format: "groupName == %@", gname)
        fetchRequest.predicate = predicate
        
        do{
            contactData = try context.fetch(fetchRequest)
            return contactData
        } catch {
            return contactData
        }
        
    }
    
    
}

