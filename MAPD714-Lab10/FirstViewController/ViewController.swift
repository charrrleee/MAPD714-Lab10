//
//  ViewController.swift
//  MAPD714-Lab10
//
//  Created by Charlene Cheung on 16/11/2022.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet var lineFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fileURL = self.dataFileURL()

        if (FileManager.default.fileExists(atPath: fileURL.path!)) {
            if let array = NSArray(contentsOf: fileURL as URL) as? [String] {
                for i in 0..<array.count {
                    lineFields[i].text = array[i]
                }
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
        print("in application will resign active")
//         let array = (self.lineFields as NSArray).value(forKey: "text") as! NSArray
        let array: NSMutableArray = []
        for line in self.lineFields
        {
            array.add(line.text!)
        }
         array.write(to: fileURL as URL, atomically: true)
        }

}

