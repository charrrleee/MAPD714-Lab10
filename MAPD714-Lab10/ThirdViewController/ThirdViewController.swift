//
//  ThirdViewController.swift
//  MAPD714-Lab10
//
//  Created by Charlene Cheung on 16/11/2022.
//

import Foundation
import SQLite3
import UIKit

class ThirdViewController: UIViewController
{
    @IBOutlet var lineFields:[UITextField]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var database:OpaquePointer? = nil
        var result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        let createSQL = "CREATE TABLE IF NOT EXISTS FIELDS " +
                            "(ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table")
            return
        }
        
        let query = "SELECT ROW, FIELD_DATA FROM FIELDS ORDER BY ROW"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let row = Int(sqlite3_column_int(statement, 0))
                let rowData = sqlite3_column_text(statement, 1)
                let fieldValue = String.init(cString: rowData!)
                lineFields[row].text = fieldValue
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationWillResignActive(notification:)),
            name: UIScene.willDeactivateNotification,
            object: nil
        )

    }
    func dataFilePath() -> String
    {
        let urls = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("data.sqlite").path
        return url!
    }
    
    @objc func applicationWillResignActive(notification:NSNotification)
    {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        for i in 0..<lineFields.count  {
            let field = lineFields[i]
            let update = "INSERT OR REPLACE INTO FIELDS (ROW, FIELD_DATA) " +
            "VALUES (?, ?);"
            var statement:OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                let text = field.text
                sqlite3_bind_int(statement, 1, Int32(i))
                sqlite3_bind_text(statement,
                                  2,
                                  NSString(string: text!).utf8String,
                                  -1,
                                  nil)
            }
            let result = sqlite3_step(statement)
            if result != SQLITE_DONE {
                print("Error updating table")
                sqlite3_close(database)
                return
            }
            print("update result ", result)
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
