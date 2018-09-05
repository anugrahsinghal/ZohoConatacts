//
//  withImage.swift
//  ZohoContacts
//
//  Created by Administrator on 26/06/18.
//  Copyright © 2018 Administrator. All rights reserved.
//
//////////// this file is not needed
import UIKit
import Contacts



class imageViewController: UITableViewController {
    
    var peopleData:[Contact] = [] //to store data fetched from api
    let contactData:[GroupsData]? = nil // this is core data array format
    
    let cellId = "cellId"
    
    var isGroupedByCompany = false
    var groupedContacts = [[Contact]]()
    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(CustomContactCell.self, forCellReuseIdentifier: cellId)
        
        //api fetch
        
        let jsonUrlString = "https://demo6380956.mockable.io/timeapi"

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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print(self.peopleData.count , " Contacts here")
                    for person in self.peopleData{
                        self.createTheContactInDBandContacts(creationData: person)
                    }
                    self.fetchContactsfromPhone()
//                    self.oldcontactfetchfromgroup(fetchedPeopleData: self.peopleData)
//                    self.saveToCoreData(peopleData: self.peopleData)
//                    self.saveGroupToCoreData(peopleData: self.peopleData)
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
//            addcontacttogroup(groupName: creationData.groupName!, contact: newContact)
            print("creation complete")
        } catch {
            print("Error occuurred when creating contacts")
        }
        
//        addToDB(DbCreationdata:creationData)
    }
    
    private func fetchContactsfromPhone() {
        print("Attempting to fetch contacts")
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Faled to request access ",err)
                return
            }
            
            if granted {
                print("Access Granted!")
                
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do{
                    try self.store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerToStopEnumerating) in
                        
                        print(contact.givenName ,"  ", contact.phoneNumbers.first?.value.stringValue as Any)
                        
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
