//
//  NotificaionModel.swift
//  TouchBase
//
//  Created by IOS on 29/06/20.
//  Copyright © 2020 Parag. All rights reserved.
//

import Foundation
let notificationTable="Notification_Table"
enum State
{
    case All
    case ByMessage
    case Defaults
    
}
class NotificaioModel {
    
//    private var ids:String=""
//    private  var title:String=""
//    private var details:String=""
//    private  var expiry_date:String=""
//    private var notify_date:String=""
//    private var sort_date:Date?=nil
//    private var flag:String=""
//    private var NotifyType:String = ""
//    private var ClubDistrictType:String = ""
    private var message:String = ""
   
    
    func setMessage(message:String)
    {
        self.message=message
    }
//    func setTitle(title:String)
//    {
//        self.title=title
//    }
//    func getNotifyType()-> String
//        {
//            return NotifyType
//        }
//        func setNotifyType(NotifyType:String)
//        {
//            self.NotifyType=NotifyType
//        }
//    
//    func getClubDistrictType()-> String
//        {
//            return ClubDistrictType
//        }
//        func setIDs(ClubDistrictType:String)
//        {
//            self.ClubDistrictType=ClubDistrictType
//        }
//    
//     func getIds()-> String
//     {
//         return ids
//     }
//     func setIDs(ids:String)
//     {
//         self.ids=ids
//     }
//     
//     
//     func getTitle()-> String
//     {
//         return title
//     }
//     func setTitle(title:String)
//     {
//         self.title=title
//     }
//
//     
//     func getDetails()-> String
//     {
//         return details
//     }
//     func setDetails(details:String)
//     {
//         self.details=details
//     }
//
//     
//     func getNotifyDate()-> String
//     {
//         return notify_date
//     }
//     func setNotifyDate(notifyDate:String)
//     {
//         self.notify_date=notifyDate
//     }
//
//     
//     func getExpiryDate()-> String
//     {
//         return expiry_date
//     }
//     func setExpiryDate(expirydate:String)
//     {
//         self.expiry_date=expirydate
//     }
//
//     func getSortDate() -> Date
//     {
//         return sort_date!
//     }
//     func setSortDate(sort_date:Date)
//     {
//         self.sort_date=sort_date
//     }
//
//     func getFlag()-> String
//     {
//         return flag
//     }
//     func setFlag(flag:String)
//     {
//         self.flag=flag
//     }

     func saveNotificationDetails(nsData:NSDictionary)
     {
        var title:String=""
        var clubDistrictType:String=""
        var msgID:String=""
        var notifyType:String=""
        var notificationDate:String=""
        var expirationDate:String=""
        let date=Date()
        
        if let aps = nsData.object(forKey: "aps") as? NSDictionary
        {
            if let alert = aps.object(forKey: "alert") as? NSDictionary
            {
                if let titles = alert.object(forKey: "title") as? String
                {
                    if titles.contains("\n")
                    {
                        let aTitle = titles.split(separator: "\n")
                        title=String(aTitle[0])
                    }
                    else
                    {
                        title=titles
                    }
                }
                if let body = alert.object(forKey: "body") as? String
                {
                    clubDistrictType = body
                }
            }
        }
        
//        if let messageID = nsData.object(forKey: "gcm.message_id") as? String
//        {
//            msgID = messageID
//            self.deleteNotification(byMsgID: msgID,state: .ByMessage)
//        }
        
        if let nType = nsData.object(forKey: "type") as? String
        {
            notifyType = nType
        }
        
        let df:DateFormatter=DateFormatter()
         df.dateFormat="dd MMM yyyy hh:mm a"
         notificationDate=df.string(from: date)
        
         let now = Calendar.current.dateComponents(in: .current, from: Date())
         let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 3)
         if  let expiryDates = Calendar.current.date(from: tomorrow)
         {
         df.dateFormat="dd/MM/YYYY"
         expirationDate = df.string(from: expiryDates)
         }

        var strings:String=""
        if notifyType == "PopupNoti"
        {
            strings = (nsData.object(forKey: "msg") as? String)!
        }
        else{
        let jsonData = try! JSONSerialization.data(withJSONObject: nsData, options: [])
        strings = String(data: jsonData, encoding: .utf8)!
        }
        
        print("Store jSonString Notification \(strings)")
        
    
    title=title.replacingOccurrences(of: "'", with: "")
    strings=strings.replacingOccurrences(of: "'", with: "")
        
    let sqlQuery="Insert into \(notificationTable) (MsgID,Title,Details,Type,ClubDistrictType,NotifyDate,ExpiryDate,SortDate,ReadStatus) values ('\(msgID)','\(title)','\(strings)','\(notifyType)','\(clubDistrictType)','\(notificationDate)','\(expirationDate)','\(date)','UnRead')"
    
    let contactDB = FMDatabase(path: getDatabasePAth() as String)
    if contactDB == nil
    {
    }
   else if (contactDB?.open())!
    {
        print("1.Notification Insert Query::\(sqlQuery)")
        let result = contactDB?.executeStatements(sqlQuery)
        if (result == nil)
        {
            print("ErrorAi: \(contactDB?.lastErrorMessage())")
        }
        else
        {
            print("success saved")
        }
    }
    else
    {
    }
 }
    
 func deleteNotification(byMsgID:String,state:State)
 {
   var sqlQuery:String=""
    switch state {
    case .All:
        sqlQuery = "Delete from \(notificationTable)"
    case .ByMessage:
        sqlQuery = "Delete from \(notificationTable) where MsgID = '\(byMsgID)'"
    case .Defaults:
        var expiryDate:String=""
        let date:Date=Date()
        let df:DateFormatter=DateFormatter()
        df.dateFormat="dd/MM/YYYY hh:mm a"
        expiryDate=df.string(from: date)
        sqlQuery = "Delete from \(notificationTable) where SortDate <= date('now','-2 day')"
    }
       
        let contactDB = FMDatabase(path: getDatabasePAth() as String)
        if contactDB == nil {
        }
        else if (contactDB?.open())! {
            let result = contactDB?.executeStatements(sqlQuery)
            if (result == nil) {
                print("ErrorAi: \(contactDB?.lastErrorMessage())")
            } else {
                print("success delete")
            }
        } else {
        }
        contactDB?.close()
   }
    
    func getNotificationCount(byMsgID:String,state:String,completion: @escaping(String)->()) //-> String
    {
        var sqlQuery:String=""
        let countArray:NSMutableArray=NSMutableArray()
        if state == "ByMessage"
        {
            sqlQuery = "Select MsgID from \(notificationTable) where MsgID= '\(byMsgID)'"
        }
        else
        {
            sqlQuery = "Select MsgID from \(notificationTable) where ReadStatus='UnRead' "
            print(sqlQuery)
        }
        
        let contactDB = FMDatabase(path: getDatabasePAth() as String)
        if contactDB == nil {
        }
        else if (contactDB?.open())!
        {
            let results:FMResultSet? = contactDB?.executeQuery(sqlQuery, withArgumentsIn: nil)
            while results?.next() == true
            {
                let dd = NSMutableDictionary()
                dd.setValue((results?.string(forColumn: "MsgID"))! as String, forKey:"msgid")
                countArray.add(dd)
            }
            completion(String(countArray.count))
        }
        else{
            completion("0")
        }
        
      //return "0"
    }
    
    func getAllNotificationDetail() -> NSMutableArray
    {
        let sqlQuery="Select * from \(notificationTable) order by ReadStatus Desc,SortDate Desc"
        let detailArray:NSMutableArray = NSMutableArray()
        let contactDB = FMDatabase(path: getDatabasePAth() as String)
        if contactDB == nil {
        }
        else if (contactDB?.open())!
        {
            let results:FMResultSet? = contactDB?.executeQuery(sqlQuery, withArgumentsIn: nil)
            while results?.next() == true
            {
                let dd = NSMutableDictionary()
                dd.setValue(results?.string(forColumn: "MsgID"), forKey: "MsgID")
                dd.setValue((results?.string(forColumn: "Title"))! as String, forKey:"title")
                dd.setValue((results?.string(forColumn: "Details"))! as String, forKey:"details")
                dd.setValue((results?.string(forColumn: "NotifyDate"))! as String, forKey:"notifyDate")
                dd.setValue((results?.string(forColumn: "Type"))! as String, forKey:"type")
                dd.setValue((results?.string(forColumn: "ClubDistrictType"))! as String, forKey:"clubDistrictType")
                dd.setValue(results?.string(forColumn: "ReadStatus"), forKey: "ReadStatus")
                detailArray.add(dd)
            }
         }
        print(detailArray)
       return detailArray
    }
    
    func changeReadStatus(ofMsgID:String,completion: @escaping(String)->())
    {
        
        let sqlQuery="Update \(notificationTable) set ReadStatus='Read' where MsgID= '\(ofMsgID)'"
        
        let contactDB = FMDatabase(path: getDatabasePAth() as String)
        if contactDB == nil {
        }
        else if (contactDB?.open())!
        {
        let result = contactDB?.executeStatements(sqlQuery)
        if (result == nil) {
            print("ErrorAi: \(contactDB?.lastErrorMessage())")
            completion((contactDB?.lastErrorMessage())!)
         } else {
            print("success Update")
            completion("Successfully Update Read status")
         }
        }
    }
    
    func getDatabasePAth() -> String
    {
        var databasePath : String
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("NewTouchbase.db")
        // open database
        databasePath = fileURL.path
        return databasePath
    }
}
