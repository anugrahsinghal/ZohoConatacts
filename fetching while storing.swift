//
//  fetching while storing.swift
//  ZohoContacts
//
//  Created by Administrator on 02/07/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

//////////this file is not needed
import UIKit
import Contacts

class fetchsave : UITableViewController {
    
    var peopleData:[Contact] = [] //to store data fetched from api
    let contactData:[GroupsData]? = nil // this is core data array format
    
    let cellId = "cellId"
    
    var isGroupedByCompany = false
    var groupedContacts = [[Contact]]()
    
    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CustomContactCell.self, forCellReuseIdentifier: cellId)
        
//        let c = Contact(contactType: "1", imageUrl: nil, firstName: "Shivam", lastName: "Khetan", organization: nil, department: nil, jobTitle: nil, addresses: nil, emailAddresses: nil, phoneNumbers: nil, note: nil, groupName: nil, found: nil, state: nil)
        
//        createContact(data: c)
        fetcher()
        groupToAdd()
        groupfetch()
        
        navigationItem.title = "Zoho Project"
        navigationController?.navigationBar.prefersLargeTitles = true
       
    }
    
    func createContact(data:Contact)
    {
        let contactToSave = CNMutableContact()

        contactToSave.givenName = data.firstName!
        contactToSave.familyName = data.lastName!

        let request = CNSaveRequest()
        request.add(contactToSave, toContainerWithIdentifier: nil)
        do
        {
            try store.execute(request)
            print("\n\n\n",contactToSave.identifier,"\n\n\n")
            print("Successfully saved the CNContact")
//            completion(contactToSave.identifier)
        }
        catch let error
        {
            print("CNContact saving faild: \(error)")
//            completion(nil)
        }
    }
    
    func fetcher(){
     
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Faled to request access ",err)
                return
            }
            
            if granted {
                print("Access Granted core data!")
                
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactIdentifierKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do{
                    
                    try self.store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerToStopEnumerating) in
                        if(contact.givenName == "Shivam"){
                            print("\(contact.givenName) \(contact.identifier)")
                        }
                        
                        
                    })
                } catch let err {
                    print("Failed to enumerate ",err)
                }
        
        
            }
        
        }
        
    }
    
    func groupToAdd(){
        
        let newGroup:CNMutableGroup = CNMutableGroup()
        newGroup.name = "trial group"
        let saveReq = CNSaveRequest()
        print("Adding Group")
        saveReq.add(newGroup, toContainerWithIdentifier: nil)
        do{
            try store.execute(saveReq)
            print(newGroup.identifier)
        }
        catch {
            print("Cannot add as Group \(error)")
        }
        
    }

    
    func groupfetch(){
        let groups :[CNGroup] = try! store.groups(matching: nil)
        for group in groups{
            if(group.name == "trial group"){
                print(group.identifier)
            }
        }
    }
    
    
    
}
