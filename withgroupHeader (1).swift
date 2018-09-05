////
////  withgroupHeader.swift
////  ZohoContacts
////
////  Created by Administrator on 28/06/18.
////  Copyright © 2018 Administrator. All rights reserved.
////
//
//////////// This file is not needed

import Foundation
import UIKit
import Contacts

class withgroup: UITableViewController {
    
//    var groupsData:[contactGroup] = [] //to store data fetched from api
    var contactData:[Contact] = [] // this store contact data per group
    var groupNames:[String] = []
    
    let cellId = "cellId"
    
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
                
                let time = datawtime.createdTime
                let allcontactinfo =  datawtime.allcontact
                
//                let RFC3339DateFormatter = DateFormatter()
//                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.ssZZZZZ"//"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//                /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
//                let string = "1997-07-16T19:20:30.45+01:00"// "1996-12-19T16:39:57-08:00"
//                let date = RFC3339DateFormatter.date(from: string)
//
                
                let date = Date()
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions.insert(.withFractionalSeconds)
                formatter.timeZone = TimeZone.current// formatter.formatOptions// this is only available effective iOS 11

                print("\n\n\n",formatter.string(from: date),"\n\n\n")
                print("\n\n\n",formatter.date(from: time!) as Any,"\n\n\n")
                
                
                print("Time \n",time as Any)
                print("\n\nFIRST Contact \n\n",allcontactinfo.first as Any)
                print("\n\nAll Contacts \n\n",allcontactinfo as Any)
//                print("\n\n\n",date?.timeIntervalSince1970)
                
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
    
    
}
//
