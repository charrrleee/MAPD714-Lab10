//
//  SecondViewController.swift
//  MAPD714-Lab10
//
//  Created by Charlene Cheung on 16/11/2022.
//

import Foundation
import UIKit

class SecondViewController: UIViewController
{
    fileprivate static let rootKey = "rootKey"
    @IBOutlet var lineFields:[UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fileURL = self.dataFileURL()
        if (FileManager.default.fileExists(atPath: fileURL.path!))
        {
            if let array = NSArray(contentsOf: fileURL as URL) as? [String]
            {
                for i in 0..<array.count {
                    lineFields[i].text = array[i]
                }
            }
            let data = NSData(contentsOf: fileURL as URL)
//            let unarchiver = NSKeyedUnarchiver(forReadingWith: data as! Data)
            
            do {
                let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data! as Data)
                

                let fourLines = unarchiver.decodeObject(forKey: SecondViewController.rootKey)
                as! FourLines
                unarchiver.finishDecoding()
                
                if let newLines = fourLines.lines {
                    for i in 0..<newLines.count {
                        lineFields[i].text = newLines[i]
                    }
                }
            } catch {
                print("error")
            }
            
        }
        
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(
            self,selector: #selector(self.applicationWillResignActive(notification:)),
                                               name: UIScene
            .willDeactivateNotification, object: nil)
    }
    
    func dataFileURL() -> NSURL
    {
        let urls = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)
        var url: NSURL?
        url = URL(fileURLWithPath: "") as NSURL?
        do
        {
            url = urls.first?.appendingPathExtension("data.plist") as NSURL?
        }
        catch
        {
            print("Error is \(error)")
        }
        return url!
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        let fileURL = self.dataFileURL()
        let fourLines = FourLines()
        let array = (self.lineFields as NSArray).value(forKey: "text") as! [String]
        fourLines.lines = array
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(fourLines, forKey: SecondViewController.rootKey)
        archiver.finishEncoding()
        data.write(to: fileURL as URL, atomically: true)

        } // end applicationWillResignActive
}
