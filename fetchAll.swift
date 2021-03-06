//
//  fetchAll.swift
//  ZohoContacts
//
//  Created by Administrator on 02/07/18.
//  Copyright © 2018 Administrator. All rights reserved.
//
//////////// This file is not needed

import UIKit
import Contacts

class fecthAll : UITableViewController {
    
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
                    for person in self.peopleData{
                        self.updateContact(data: person)
                    }
                    self.oldcontactfetchfromgroup(fetchedPeopleData: self.peopleData)
                    self.saveToCoreData(peopleData: self.peopleData)
                    self.saveGroupToCoreData(peopleData: self.peopleData)
                }
            } catch let jsonErr {
                print("Error in Json",jsonErr)
            }
        }
        task.resume()
        
        //end of api fetch
        
        navigationItem.title = "Zoho Project"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group by Company", style: .plain, target: self, action: #selector(handleGrouping))
        
    }
    
    //TODO: CORE DATA SERVICES
    
    func saveToCoreData(peopleData : [Contact]) {
        
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
                        
                        if(contact.identifier.contains("ABPerson")){
                            var uidData:[String] = []
                            DispatchQueue.main.async {
                                let core = CoreDataHandler.fetchObject()
                                for i in core!{
                                    uidData.append(i.uid!)
                                }
                            }
                            DispatchQueue.main.async {
                                if(uidData.contains(contact.identifier)==false){ //if the value that us fetch from api and then inserting new contacts is not already in db then add those values
                                    if( CoreDataHandler.saveObject(uid: contact.identifier, firstName: contact.givenName,
                                                                   lastName: contact.familyName, phoneNo: (contact.phoneNumbers.first?.value.stringValue)!,found:"NO") ) {
                                        
                                        print("Value inserted to database")
                                    } else {
                                        
                                    }
                                }
                            }
                        }
                    })
                } catch let err {
                    print("Failed to enumerate ",err)
                }
                
            } else {
                print("Acceess Denied...!!!")
            }
            DispatchQueue.main.async {
                
                let core = CoreDataHandler.fetchObject()
                print(core?.count as Any)
                for i in core!{
                    print("CDdata  ",i.uid!)
                }
            }
        }
    }
    
    func saveGroupToCoreData(peopleData : [Contact]) {
        
        var apiFetchedGroups :[String] = []
        for people in peopleData{
            if(apiFetchedGroups.contains(people.groupName!)==false){
                apiFetchedGroups.append(people.groupName!)
            }
        }
        let groups :[CNGroup] = try! store.groups(matching: nil)
        
        for group in groups{
            for fetchedGroups in apiFetchedGroups{
                if(group.name==fetchedGroups){
                    DispatchQueue.main.async {
                        if(GroupCoreDataHandler.saveObject(guid: group.identifier, groupName: group.name)){
                            print("Group Added to Core Data")
                        }
                    }
                }
            }
        }
    }
    
    
    func changeButtonToOriginal(){
        navigationItem.rightBarButtonItem?.title = "Group by Company"
    }
    
    func changeButtonToReset() {
        navigationItem.rightBarButtonItem?.title = "Reset"
    }
    
    
    @objc func handleGrouping(){
        //here grouping will be handled
        if groupedContacts.count > 0 {
            groupedContacts.removeAll()
            tableView.reloadData()
            changeButtonToOriginal()
            return
        }
        
        isGroupedByCompany = true
        let groupDictionary = Dictionary(grouping: peopleData) { (person) -> String in
            return person.groupName ?? "Managed"
        }
        
        let keys = groupDictionary.keys.sorted()
        
        keys.forEach({
            groupedContacts.append(groupDictionary[$0]!)
        })
        tableView.reloadData()
        changeButtonToReset()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedContacts.count > 0 ? groupedContacts.count : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupedContacts.count > 0{
            return groupedContacts[section].count
        }
        return peopleData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell=tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let cell = CustomContactCell(style: .subtitle, reuseIdentifier: cellId)
        let people: Contact
        
        if groupedContacts.count > 0 {
            people = groupedContacts[indexPath.section][indexPath.row]
        } else {
            people = peopleData[indexPath.row]
        }
        
        cell.textLabel?.text = "\(people.firstName!) \(people.lastName!)"
        cell.detailTextLabel?.text = "\(people.phoneNumbers?.main ?? "")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if groupedContacts.count == 0 {
            return nil
        }
        
        let label=UILabel()
        if isGroupedByCompany {
            if let company = groupedContacts[section].first?.groupName {
                label.text = "\(company)"
            }
        }
        
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.green
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return groupedContacts.count == 0 ? 0 : 30
    }
    
    func convertToPhoneFormat(phoneNumber : String?) -> String{
        var noarr = Array(phoneNumber ?? "")
        
        if noarr.count == 10 {
            let pno:String = "(\(noarr[0])\(noarr[1])\(noarr[2])) \(noarr[3])\(noarr[4])\(noarr[5])-\(noarr[6])\(noarr[7])\(noarr[8])\(noarr[9])"
            return pno
        }
        return ""
    }
    
    func createContacts(data:Contact) {
        print("Inside Create Contacts")
        let newContact = CNMutableContact()
        
        newContact.givenName = data.firstName!
        newContact.familyName = data.lastName!
        
        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "myhome@example.com" as NSString)
        let workEmail = CNLabeledValue(label: CNLabelWork, value: "mywork@zoho.com" as NSString)
        newContact.emailAddresses = [homeEmail,workEmail]
        
        let phoneNo1 = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: convertToPhoneFormat(phoneNumber: data.phoneNumbers?.main)))
        //        let phoneNo = CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: "(856) 582-4888"))
        newContact.phoneNumbers = [phoneNo1]
        
        let birthday = NSDateComponents()
        birthday.day = 29
        birthday.month = 8
        birthday.year = 1997
        newContact.birthday = birthday as DateComponents
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
            addcontacttogroup(groupName: data.groupName!, contact: newContact)
        } catch {
            print("error occuurred when updating contacts")
        }
        
    }
    
    func addNewGroup(name:String) {
        let groups :[CNGroup] = try! store.groups(matching: nil)
        var flag = 0
        for group in groups{
            if(group.name == name){
                flag = 1
                print("Already Present")
                return
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
            }
            catch {
                print("Cannot add as Group \(error)")
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
            addNewGroup(name: groupName)
        }
        
    }
    
    func updateContact(data : Contact){
        
        print("Inside update contacts")
        
        //        let predicate = CNContact.predicateForContacts(matchingName: data.lastName)
        
        let groups :[CNGroup] = try! store.groups(matching: nil)
        var count = groups.count
        for group in groups{
            count-=1
            if(group.name != data.groupName && count==0){
                addNewGroup(name: (data.groupName ?? nil)!)
            }
        }
        
        let filteredGroups = groups.filter { $0.name == data.groupName }
        guard let workGroup = filteredGroups.first else {
            print("No Work group")
            return
        }
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: workGroup.identifier)
        let keysToFetch = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let contacts :[CNContact] = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        if(contacts.count == 0){
            createContacts(data: data)
            return
        }
        
        for contact in contacts{
            if(contact.givenName == data.groupName && contact.phoneNumbers.first?.value.stringValue == convertToPhoneFormat(phoneNumber: data.phoneNumbers?.main) )
            {
                print("Updating for contact \(contact.givenName) \(contact.familyName)")
                let updatedContact = contact.mutableCopy() as! CNMutableContact
                updatedContact.givenName = data.groupName ?? ""
                
                //MARK : implement to see what data has changed an then update that data
                
                //       let newEmail:CNLabeledValue = CNLabeledValue(label: CNLabelHome, value: "onlyfromapi@example.com" as NSString)
                //              updatedContact.emailAddresses.append(newEmail)
                //            let x = updatedContact.emailAddresses.remove(at: 0)
                //            print(x)
                
                let saveReq = CNSaveRequest()
                saveReq.update(updatedContact)
                do{
                    try store.execute(saveReq)
                    addcontacttogroup(groupName: data.groupName!, contact: updatedContact)
                } catch{
                    print("Cannot update as no contact")
                }
            }
        }
    }
    
    func deleteContact(data:CNContact){
        
        print("Inside Delete contacts")
        let contactToDelete = data.mutableCopy() as! CNMutableContact //contact.mutableCopy() as! CNMutableContact
        let saveReq = CNSaveRequest()
        saveReq.delete(contactToDelete)
        try! store.execute(saveReq)
        //}
    }
    
    func removeGroup(groupName: String){
        print("Removing group ",groupName)
        
        let groups :[CNGroup] = try! store.groups(matching: nil)
        for group in groups {
            if(group.name == groupName){
                let groupCopy = group.mutableCopy() as! CNMutableGroup
                let saveReq = CNSaveRequest()
                saveReq.delete(groupCopy)
                do{
                    try store.execute(saveReq)
                } catch {
                    print("Cannot remove Group \(error)")
                }
                break
            }
        }
        
        DispatchQueue.main.async {
            let todeleteindb = GroupCoreDataHandler.filterData(gname: groupName)
            if (GroupCoreDataHandler.deleteObject(person: (todeleteindb?.first)!)){
                print("Group Deletion Complete from database")
            }
        }
    }
    
    //TODO group fetch and deletion concept
    func oldcontactfetchfromgroup(fetchedPeopleData:[Contact]){ // inside this we will pass the new data fetched
        //        CoreDataHandler.cleanDelete()
        //        GroupCoreDataHandler.cleanDelete()
        
        let core = CoreDataHandler.fetchObject()
        print(core?.count as Any)
        for i in core!{
            print("CDdata  ",i.uid!)
        }
        //new people DON'T DELETE VARAIABLE
        var newPeopleData = fetchedPeopleData
        //data DON'T DELETE VARAIABLE
        let oldGroups = GroupCoreDataHandler.fetchObject()
        var allGroup :[String] = []
        
        for oldg in oldGroups!{
            print(oldg.groupName as Any,oldg.guid as Any)
            if(allGroup.contains(oldg.groupName!)==false){
                allGroup.append(oldg.groupName!)
            }
        }
        for data in newPeopleData {
            if(allGroup.contains(data.groupName!)==false){
                allGroup.append(data.groupName!)
            }
        }
        
        var groupsToDelete :[String] = []
        //        var oldgnam:[String] = []
        var flag = 0
        for oldg in oldGroups!{
            flag=0
            for data in newPeopleData {
                if(oldg.groupName == data.groupName){
                    flag=1
                    break
                }
            }
            if(flag==0){
                groupsToDelete.append(oldg.groupName!)
            }
        }
        
        print("Groups to delete ",groupsToDelete)
        
        var newGroupNames:[String] = []
        //var oldContacts:[CNMutableContact] = []
        var oldContacts1:[Peoplenew] = []
        let groups :[CNGroup] = try! store.groups(matching: nil)
        for data in allGroup{
            let filteredGroups = groups.filter { $0.name == data }
            guard let workGroup = filteredGroups.first else {
                print("No Work group")
                newGroupNames.append(data)
                return
            }
            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: workGroup.identifier)
            let keysToFetch = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactIdentifierKey] as [CNKeyDescriptor]
            let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            for oldcontact in contacts{
                //oldContacts.append(oldcontact.mutableCopy() as! CNMutableContact)
                oldContacts1.append(Peoplenew(uid:oldcontact.identifier,firstName: oldcontact.givenName, lastName: oldcontact.familyName, phoneNo: oldcontact.phoneNumbers.first?.value.stringValue, companyName: "", found: "NO"))
            }//append all the old contact that were in that group
        }//for loop ends for each group
        //so finally this will contain all the old contact in all the groups
        
        //create all new groups that were found in api
        for newGroup in newGroupNames{
            addNewGroup(name: newGroup)
        }
        
        //A Dictionary/Map FOR OLD NAMES
        var oldContactDictionary = [String:Int]()
        for (indexold,oldContact) in oldContacts1.enumerated(){
            oldContactDictionary[oldContact.firstName+oldContact.lastName]=indexold
        }
        
        
        for (indexnew,newPerson) in newPeopleData.enumerated() {
            if(oldContactDictionary.keys.contains(newPerson.firstName!+newPerson.lastName!)){
                let indexold = oldContactDictionary[newPerson.firstName!+newPerson.lastName!]
                oldContacts1[indexold!].found = "YES"
                newPeopleData[indexnew].found = "YES"
                let oldContact = oldContacts1[indexold!]
                if(oldContact.phoneNo != newPerson.phoneNumbers?.main){
                    deleteContactbyuid(data: oldContact.uid)
                    createContacts(data: newPerson)
                }
            }
        }
        
        for p in newPeopleData{
            print(p.firstName!,p.found as Any)
        }
        
        for p in oldContacts1{
            print(p.firstName,p.found as Any)
        }
        
        for peopletoadd in newPeopleData{
            if(peopletoadd.found == "NO"){
                print("WE are adding a person",peopletoadd.firstName as Any,peopletoadd.found as Any)
                createContacts(data: peopletoadd)
            }
        }
        
        for peopletoremove in oldContacts1{
            if(peopletoremove.found == "NO"){
                print("WE are removing a person")
                deleteContactbyuid(data: peopletoremove.uid)
            }
        }
        
        for deleteGroups in groupsToDelete{
            removeGroup(groupName: deleteGroups)
        }
        
    }
    
    func deleteContactbyuid(data: String){
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Faled to request access ",err)
                return
            }
            
            if granted {
                print("Access Granted!")
                
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactIdentifierKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do{
                    
                    try self.store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerToStopEnumerating) in
                        if(contact.identifier == data){
                            let contactToDelete = contact.mutableCopy() as! CNMutableContact
                            let saveReq = CNSaveRequest()
                            print("Deleting contact",contact.givenName)
                            saveReq.delete(contactToDelete)
                            try! self.store.execute(saveReq)
                            DispatchQueue.main.async {
                                let todeleteindb = CoreDataHandler.filterData(uid: data)
                                if (CoreDataHandler.deleteObject(person: (todeleteindb?.first)!)){
                                    print("Deletion Complete from database")
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

    


