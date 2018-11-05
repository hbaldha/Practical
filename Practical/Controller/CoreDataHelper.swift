//
//  CoreDataHelper.swift
//  Practical
//
//  Created by Hardik on 25/10/18.
//

import UIKit
import CoreData
import SwiftyJSON

class CoreDataHelper: NSObject {

    static let shared = CoreDataHelper()

     func saveContext(){
        do {
            try AppDelegate.shared.persistentContainer.viewContext.save()
        }catch {
            
        }
    }
    
    func context() -> NSManagedObjectContext{
        return AppDelegate.shared.persistentContainer.viewContext
    }
    
    // Fetch data
    func fetchMusicDataFromLocalCoreData() -> [Music] {
        
        var arrayMusicData = [Music]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Music")
        
        do {
            arrayMusicData = try CoreDataHelper.shared.context().fetch(fetchRequest) as! [Music]
        } catch {
            print("No contacts found")
        }
        return arrayMusicData
    }
    
    // delete all record
    func deleteAllRecords() {
        //getting context from your Core Data Manager Class
        let managedContext = CoreDataHelper.shared.context()
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Music")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There is an error in deleting records")
        }
    }
    
    // save all record
    func saveMusicDataToDB(resultJson:JSON) {
        
        let encyptionHelperObj = EncryptionHelper()
        
        if let MusicEntity = NSEntityDescription.insertNewObject(forEntityName: "Music", into:CoreDataHelper.shared.context()) as? Music {
            
            if let encryptionkey = UserDefaults.standard.value(forKey: "encryptionKey") as? String {
                do {
                    let encryptedName  = try encyptionHelperObj.encryptMessage(message:resultJson["artistName"].stringValue, encryptionKey: encryptionkey)
                    
                    MusicEntity.artistName = encryptedName
                    
                    let encryptedartworkUrl100 = try encyptionHelperObj.encryptMessage(message:resultJson["artworkUrl100"].stringValue, encryptionKey: encryptionkey)
                    MusicEntity.artworkUrl100 = encryptedartworkUrl100
                    
                    CoreDataHelper.shared.saveContext()
                } catch{
                    
                }
                
            }
            
        }
    }
}

