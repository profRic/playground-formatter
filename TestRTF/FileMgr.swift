//
//  FileMgr.swift
//  TestRTF
//
//  Created by Ric Telford on 3/11/17.
//  Copyright © 2017 Ric Telford. All rights reserved.
//

import UIKit

class FileMgr: NSObject {
    
        var document: MyDocument?
        var documentURL: URL?
        var ubiquityURL: URL?
        var metaDataQuery: NSMetadataQuery?
    
    func setup() {
        let filemgr = FileManager.default
        if let tempUbiquityURL = filemgr.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                ubiquityURL = tempUbiquityURL.appendingPathComponent("playground.txt")
                print(ubiquityURL as Any)
                metaDataQuery = NSMetadataQuery()
                metaDataQuery?.predicate = NSPredicate(format: "%K like 'storyboard.txt'", NSMetadataItemFSNameKey)
                metaDataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
                
                NotificationCenter.default.addObserver(self, selector: #selector(FileMgr.metadataQueryDidFinishGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: metaDataQuery)
                metaDataQuery!.start()
            } else {
                print("error opening file - probably forgot to log into iCloud")
            }
    }
    
    func metadataQueryDidFinishGathering(_ notification: Notification) -> Void
    {
            let query: NSMetadataQuery = notification.object as! NSMetadataQuery
            
            query.disableUpdates()
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query)
            query.stop()
            let results = query.results
            
            if query.resultCount == 1 {
                let resultURL =
                    (results[0] as AnyObject).value(forAttribute: NSMetadataItemURLKey) as! URL
                
                document = MyDocument(fileURL: resultURL)
                
                document?.open(completionHandler: {(success: Bool) -> Void in
                    if success {
                        print("iCloud file open OK as: \(self.document?.userText)")
                        self.ubiquityURL = resultURL
                    } else {
                        print("iCloud file open failed")
                    }
                })
            } else {
                document = MyDocument(fileURL: ubiquityURL!)
                
                document?.save(to: ubiquityURL!, for: .forCreating, completionHandler: {(success: Bool) -> Void in
                    if success {
                        print("iCloud create OK")
                    } else {
                        print("iCloud file open failed")
                    }
                })
            }
    }
        
        
    func saveFile(text: String) {
            if document != nil {
                document!.userText = text
                document?.save(to: ubiquityURL!, for: .forOverwriting, completionHandler: {(success: Bool) -> Void in
                    if success {
                        print("Save overwrite OK")
                    } else {
                        print("Save overwrite failed")
                    }
                })
            } else {
                print("document does not exist - error in creating")
            }
        }
}

class MyDocument: UIDocument {
    
    var userText: String? = "Some Sample Text"
    
    override func contents(forType typeName: String) throws -> Any {
        if let content = userText {
            let length = content.lengthOfBytes(using: String.Encoding.utf8)
            return Data(bytes: UnsafePointer<UInt8>(content), count: length)
        }
        else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? Data {
            userText = NSString(bytes: (contents as AnyObject).bytes, length: userContent.count, encoding: String.Encoding.utf8.rawValue) as? String
        }
    }
    
}
