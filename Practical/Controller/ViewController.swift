//
//  ViewController.swift
//  Practical
//
//  Created by Hardik on 24/10/18.
//

import UIKit

import SwiftyJSON
import SDWebImage

let JsonURLToFetchMusicData = "https://rss.itunes.apple.com/api/v1/us/apple-music/new-releases/all/100/explicit.json"


class ViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var collectionViewMusic: UICollectionView!
    var arrayMusicData = [Music]()
    let encyptionHelperObj = EncryptionHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(AppDelegate.shared.applicationDocumentsDirectory())
        self.callAPIToGetMusicDataFromServer()
        
        do {
            let encryptionKey = try encyptionHelperObj.generateEncryptionKey(withPassword: "!@#$")
            UserDefaults.standard.set(encryptionKey, forKey: "encryptionKey")
            UserDefaults.standard.synchronize()
            
        } catch {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {

    // get data from server
    func callAPIToGetMusicDataFromServer()  {
        
        NetworkManager.sharedInstance.get(JsonURLToFetchMusicData, parameters: [:], success: { (response) in
            let responseJSON = JSON(response!)
            if let tmpfeedDictionary = responseJSON["feed"].dictionary {
                if let resultArray = tmpfeedDictionary["results"]?.arrayValue {
                    
                    CoreDataHelper.shared.deleteAllRecords()
                    for dict in resultArray {
                        CoreDataHelper.shared.saveMusicDataToDB(resultJson: dict)
                    }
                    
                    self.arrayMusicData = CoreDataHelper.shared.fetchMusicDataFromLocalCoreData()
                    
                    self.loadingView.isHidden = true
                    self.collectionViewMusic.dataSource = self
                    self.collectionViewMusic.reloadData()
                }
            }
            
        }) { (fail) in
            print("fail to get data from server")
        }
    }
}


extension ViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMusicData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IdentifireMusicCell", for: indexPath) as? MusicCell {
            
            if let encryptionkey = UserDefaults.standard.value(forKey: "encryptionKey") as? String {
                do {
                    let artistName =  try encyptionHelperObj.decryptMessage(encryptedMessage: arrayMusicData[indexPath.row].artistName!, encryptionKey: encryptionkey)
                    cell.LblArtistName.text = artistName
                    
                    let imageArtUrl100 =  try encyptionHelperObj.decryptMessage(encryptedMessage: arrayMusicData[indexPath.row].artworkUrl100!, encryptionKey: encryptionkey)
                    
                    cell.imageArtUrl.sd_setImage(with: URL(string: imageArtUrl100), placeholderImage: UIImage(named: "placeholder"))

                    return cell
                }catch{
                    
                }
            }
        }
        return UICollectionViewCell()
    }
}


