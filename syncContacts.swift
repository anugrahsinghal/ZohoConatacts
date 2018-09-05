//
//  syncContacts.swift
//  ZohoContacts
//
//  Created by Administrator on 02/07/18.
//  Copyright © 2018 Administrator. All rights reserved.
//
//////////// This file is not needed

import UIKit
import Contacts

class syncContacts : UITableViewController {
    
    var peopleData:[Contact] = [] //to store data fetched from api
    let contactData:[GroupsData]? = nil // this is core data array format
    
    let cellId = "cellId"
    
    var isGroupedByCompany = false
    var groupedContacts = [[Contact]]()

    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetchContactsfromPhone()
        
        tableView.register(CustomContactCell.self, forCellReuseIdentifier: cellId)
        
        //api fetch
        
        let jsonUrlString = "https://demo8476231.mockable.io"
        
        guard let url = URL(string: jsonUrlString) else
        { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data  else {return}
            
            do {
                let datawtime = try JSONDecoder().decode(datawithtime.self, from: data) //Json Decoding
                
                let persons = datawtime.allcontact
                
                for var person in persons {
                    if(person.groupName == nil){
                        person.groupName = "Managed"
                        print("Group name change was initiated here for data = ",person)
                    }
                    if(person.found == nil){
                        person.found = "NO"
                        print("Found data change for",person.firstName!)
                    }
                    self.peopleData.append(person)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print(self.peopleData.count , " Contacts here")
                    self.synchronize(people: self.peopleData)
                   
                }
            } catch let jsonErr {
                print("Error in Json",jsonErr)
            }
        }
        task.resume()
        
        //end of api fetch
        
        navigationItem.title = "Zoho Project"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group by Company", style: .plain, target: self, action: #selector(handleGrouping))
        
    }
    
    func synchronize(people : [Contact]){

        for person in people{
            if((person.state) == "NEW"){
                createContacts(creationData: person)
            }
            else if((person.state) == "DELETED"){
                deletecontacts(data: person)
            }
            else if((person.state) == "UPDATED"){
                deletecontacts(data: person)
                createContacts(creationData: person)
            }
        }
    }
    
    func createContacts(creationData :Contact){
        print("Inside Create Contacts")
        
        let newContact = CNMutableContact()
        newContact.organizationName = creationData.organization!
        newContact.jobTitle = creationData.jobTitle!
        newContact.departmentName = creationData.department!
        // //       DispatchQueue.global().async {
        //            do{
        //                if(creationData.imageUrl != nil){
        //                    let url = URL(string: (creationData.imageUrl!))
        //                    let data = try Data(contentsOf: url!)
        ////                    DispatchQueue.main.async {
        //                        if let image = UIImage(data: data),
        //                            let data = UIImagePNGRepresentation(image){
        //                            newContact.imageData = data
        ////                        }
        //                    }
        //                }
        //            } catch {
        //                print("No image data for ",creationData.firstName!)
        //            }
        //  //      }
        
        guard let ctype = creationData.contactType  else {
            print("NO contact type")
            return
        }
        print("Outside")
        
        newContact.contactType = CNContactType(rawValue: Int(ctype)!)!
        newContact.namePrefix = "madame"
        newContact.nameSuffix = "sr."
        
        let address = CNMutablePostalAddress()
        address.city = (creationData.addresses?.home?.city)!
        address.state = (creationData.addresses?.home?.state)!
        address.postalCode = (creationData.addresses?.home?.postalCode)!
        address.street = (creationData.addresses?.home?.street)!
        address.country = (creationData.addresses?.work?.country)!
        
        let home = CNLabeledValue(label: CNLabelHome, value: address as CNPostalAddress)
        
        newContact.postalAddresses = [home]
        
        newContact.givenName = creationData.firstName!
        newContact.familyName = creationData.lastName!
        
        let homeEmail = CNLabeledValue(label: CNLabelHome, value: (creationData.emailAddresses!.home!) as NSString)
        let workEmail = CNLabeledValue(label: CNLabelWork, value: (creationData.emailAddresses!.work!) as NSString)
        newContact.emailAddresses = [homeEmail,workEmail]
        
        let phoneNo = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: (creationData.phoneNumbers?.main)!))
        //        let phoneNo1 = CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: "(856) 582-4888"))
        newContact.phoneNumbers = [phoneNo]
        
        let birthday = NSDateComponents()
        birthday.day = 29
        birthday.month = 8
        birthday.year = 1997
        newContact.birthday = birthday as DateComponents
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
//            addcontacttogroup(groupName: creationData.groupName!, contact: newContact)
        } catch {
            print("Error occuurred when creating contacts")
        }
        
        addToDB(DbCreationdata:creationData)
    }
    
    func addNewGroup(name:String) -> Bool{
        let groups :[CNGroup] = try! store.groups(matching: nil)
        var flag = 0
        for group in groups{
            if(group.name == name){
                flag = 1
                print("Already Present")
                return true
            }
        }
        if(flag == 0){
            
            let newGroup:CNMutableGroup = CNMutableGroup()
            newGroup.name = name
            let saveReq = CNSaveRequest()
            print("Adding Group")
            saveReq.add(newGroup, toContainerWithIdentifier: nil)
            do{
                try store.execute(saveReq)
                return true
            }
            catch {
                print("Cannot add as Group \(error)")
                return false
            }
        }
    }
    
    func addcontacttogroup(groupName:String,contact:CNMutableContact) {
        
        print("Inside adding contact to groups")
        let groups :[CNGroup] = try! store.groups(matching: nil)
        var flag = 0
        for group in groups{
            if(group.name == groupName){
                flag=1
                let saveReq = CNSaveRequest()
                saveReq.addMember(contact, to: group)
                do{
                    try store.execute(saveReq)
                } catch {
                    print("Cannot add as Group \(error)")
                }
                return
            }
        }
        if flag == 0 {
            if(addNewGroup(name: groupName)){
                addcontacttogroup(groupName: groupName, contact: contact)
            }
        }
        
    }
    
    func deletecontacts(data:Contact){
        
        let contactToDelete = CoreDataHandler.fetchObject()
        var uidForDelete:String
        for contacts in contactToDelete!{
            if(contacts.firstName!+contacts.lastName! == data.firstName!+data.lastName! && contacts.phoneNo == data.phoneNumbers?.main){
                uidForDelete = contacts.uid!
                print(uidForDelete)
                break
            }
        }
        
        
        
    }
    
    func addToDB(DbCreationdata:Contact){
        
        print("Attempting to fetch contacts in core data")
        
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
                        
                        if(contact.givenName==DbCreationdata.firstName && contact.familyName==DbCreationdata.lastName && contact.phoneNumbers.first?.value.stringValue == DbCreationdata.phoneNumbers?.main){
                            DispatchQueue.main.async {
                                if( CoreDataHandler.saveObject(uid: contact.identifier, firstName: contact.givenName,lastName: contact.familyName, phoneNo: (contact.phoneNumbers.first?.value.stringValue)!,found:"YES") ) {
                                    
                                    print("Value inserted to database")
                                    return
                                }
                            }
                            return
                        }
                    })
                } catch let err {
                    print("Failed to enumerate ",err)
                }
                
            } else {
                print("Acceess Denied...!!!")
            }
        }
    }
    
}
