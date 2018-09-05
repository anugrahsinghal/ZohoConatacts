//
//  ViewController.swift
//  ZohoContacts
//
//  Created by Administrator on 11/06/18.
//  Copyright © 2018 Administrator. All rights reserved.
//
//////////// This file is not needed
import UIKit
import Contacts

struct dbPeoples:Decodable {
    
    let uid :String
    let firstName :String
    let lastName :String
    let phoneNo :String?
    var companyName :String?
    var found:String?
    
}

class newViewController: UITableViewController {
    
    var peopleData:[Contact] = [] //to store data fetched from api
    let contactData:[GroupsData]? = nil // this is core data array format
    
    let cellId = "cellId"
    
    var isGroupedByCompany = false
    var groupedContacts = [[Contact]]()
    let store = CNContactStore()
    
    //start of view did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CustomContactCell.self, forCellReuseIdentifier: cellId)
        
        //api fetch
        
        let jsonUrlString = "https://demo8476231.mockable.io"
        
        guard let url = URL(string: jsonUrlString) else
        { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data  else {return}
            
            do {
                
                let datawtime = try JSONDecoder().decode(datawithtime.self, from: data) //Json Decoding
                
                let persons :[Contact] = datawtime.allcontact
                
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
                
                
                
                // part of main queue reomvoed here

                //fetch all contact from db with their found value compare them with new contacts
                DispatchQueue.main.async {
                    print(self.peopleData)
                    self.fetchDetailFromDb(newFetchedData: self.peopleData)
                }
                //conert them to long strings and match these contacts
                //if match found set dbfound and newfound as YES
                //when all old contact is done check which is already NO and delete them
                //also check new data and whichever marked NO create them
//              //if change found delete the old contact and add new contact + add new val to db+UID
                //repeat

                //when all db contacts have been iterated through
                //find and filter any contacts with dbfound as NO
                //delete that contact from contacts framework and then from database

                //check all new contact with newfound as NO
                //create that contact + add new val to db with uid

                //FINALLY set all dbfound values to NO
                
            } catch let jsonErr {
                print("Error in Json",jsonErr)
            }
        }
        task.resume()
        
        //end of api fetch
        
        navigationItem.title = "Zoho Project"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group by Company", style: .plain, target: self, action: #selector(handleGrouping))
        
        
    }//modification needed here
    //on view did load finishes here
    
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
            return person.groupName ?? "None"
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
        
        cell.textLabel?.text = "\(String(describing: people.firstName)) \(String(describing: people.lastName))"
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

    func fetchDetailFromDb(newFetchedData:[Contact]) {
        print("Here 1")
        //CoreDataHandler.cleanDelete()
        var newContactData:[Contact] = newFetchedData
        let core = CoreDataHandler.fetchObject() // all the data from database
        print(core?.count as Any)
        for each in core!{
            print(each.firstName as Any ,each.uid as Any)
        }
        var oldContactData:[dbPeoples]? = []
        for eachdata in core! {
            oldContactData?.append(dbPeoples(uid:eachdata.uid!,firstName: eachdata.firstName!, lastName: eachdata.lastName!, phoneNo: eachdata.phoneNo, companyName:"", found: "NO"))
        } //so now we have all the old data
        print("break 2, ", oldContactData?.isEmpty as Any)
        //convert both data to longstrings for comparision
        var oldContactDataStrings:[String]? = []
        var newContactDataStrings:[String]? = []
        var count = 0
        if(oldContactData?.isEmpty == false){
            print("Here 2")
            for data in oldContactData!{
                count+=1
                oldContactDataStrings?.append(convertoldTolongString(index: count,contact: data))
            }
        }else {
            print("Here 3")
            for data in newContactData{
                if(data.found == "NO"){
                    createTheContactInDBandContacts(creationData: data)
                }
            }
            return
        }
        count = 0
        for data in newContactData{
            count+=1
            newContactDataStrings?.append(convertTolongString(index: count,contact: data))
        }
        
        //matching old and new contacts
        for data in newContactDataStrings!{
            if(oldContactDataStrings?.contains(data) == true){
                let newContactIndex = Int(String(data.last!))
                let oldContactIndex = oldContactDataStrings?.index(of: data)
                oldContactData![oldContactIndex!].found = "YES"
                newContactData[newContactIndex!].found = "YES"
            }
        }
        
        for data in oldContactData!{
            if(data.found == "NO"){
                deleteFromDBandContactFramework(deletionData: data)
            }
        }
        
        for data in newContactData{
            if(data.found == "NO"){
                createTheContactInDBandContacts(creationData: data)
            }
        }
        
    }
    
    func convertTolongString(index:Int,contact:Contact) -> String{
        
        var longstring:String? = ""
        longstring = "hey"//(contact.firstName!+contact.lastName!+(contact.phoneNumbers?.main)!+contact.groupName+String(index))
        
        return longstring!
    }
    
    func convertoldTolongString(index:Int,contact:dbPeoples) -> String{
        
        var longstring:String? = ""
        longstring = (contact.firstName+contact.lastName+contact.phoneNo!+contact.companyName!+String(index))
        
        return longstring!
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
    
    func createTheContactInDBandContacts(creationData:Contact){
        
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
            addcontacttogroup(groupName: creationData.groupName!, contact: newContact)
        } catch {
            print("Error occuurred when creating contacts")
        }
        
        addToDB(DbCreationdata:creationData)
    }
    
    func deleteFromDBandContactFramework(deletionData:dbPeoples){
        
        let user =  CoreDataHandler.filterData(uid:deletionData.uid)
        if (CoreDataHandler.deleteObject(person: (user?.first)!)){
            print("Deletion Complete")
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
