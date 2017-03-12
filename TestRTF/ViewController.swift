//
//  ViewController.swift
//  TestRTF
//
//  Created by Ric Telford on 2/19/17.
//  Copyright © 2017 Ric Telford. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var attrString = NSAttributedString()
    var fm = FileMgr()
    var fileLength : Int!
    var rangeStart : Int!
    var rangeLength : Int!
    var outputString = ""
    var ptr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fm.setup()
        var content : String!
        let fileURL = Bundle.main.url(forResource: "TestWord", withExtension: "rtf")

        do {
            content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
        
        do {
            attrString = try NSAttributedString(data: content.data(using: String.Encoding.utf8, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType], documentAttributes: nil)
        } catch {
            print(error)
        }
        
        fileLength = attrString.length
        //print("size and info:")
        //print(attrString.size())
        //print(attrString.observationInfo as Any)
        
        // let xxxx = attrString.value(forKey: "font")
 
/* This logic not needed right now
        let attv = attrString.lineBreak(before: bef, within: xxx3)
        print(attv)
        let xx5 = bef-attv
        print(xx5)
        let xx4 = NSMakeRange(attv, xx5)
        

*/
        var rng = NSMakeRange(0, fileLength-1)
        _ = attrString.attributes(at: 1, effectiveRange: &rng)
 //       for (attrib, val) in attList {
   //         print("\(attrib) is \(val)\n")
     //   }
        rangeStart = rng.location
        rangeLength = rng.length
        
        self.textView.attributedText = attrString
        
        let menuCont: UIMenuController = UIMenuController.shared
        menuCont.isMenuVisible = true
        menuCont.arrowDirection = UIMenuControllerArrowDirection.down
        menuCont.setTargetRect(CGRect.zero, in: self.view)
        
        let menuItem1: UIMenuItem = UIMenuItem(title: "Text", action: #selector(rtfView.textItem(_:)))
        let menuItem2: UIMenuItem = UIMenuItem(title: "H1", action: #selector(rtfView.h1Item(_:)))
        let menuItem3: UIMenuItem = UIMenuItem(title: "H2", action: #selector(rtfView.h2Item(_:)))
        let menuItem4: UIMenuItem = UIMenuItem(title: "H3", action: #selector(rtfView.h3Item(_:)))
        let menuItem5: UIMenuItem = UIMenuItem(title: "Bold", action: #selector(rtfView.boldItem(_:)))
        let menuItem6: UIMenuItem = UIMenuItem(title: "Italic", action: #selector(rtfView.italicItem(_:)))
        let menuItem7: UIMenuItem = UIMenuItem(title: "Bullets", action: #selector(rtfView.bulletItem(_:)))
        let menuItem8: UIMenuItem = UIMenuItem(title: "NumList", action: #selector(rtfView.numListItem(_:)))
        let menuItems: NSArray = [menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem6,menuItem7, menuItem8]
        menuCont.menuItems = menuItems as? [UIMenuItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       print("LOW MEMORY")
    }
    
    @IBAction func pressed(_ sender: Any) {
        //print("VC from VC: \(self)")
        self.textView.selectedRange = NSMakeRange(rangeStart, rangeLength)
        self.textView.becomeFirstResponder()
    }

    
    func saveItem(value: markupType){
        let substr = attrString.attributedSubstring(from: NSMakeRange(rangeStart, rangeLength))
        let newString = substr.string
        var writeString = ""
        
        switch value {
        case .text:
            writeString = formatString(wrapped: true, start: "", string: newString, end: "\n")
        case .bold:
            writeString = formatString(wrapped: false, start: " ** ", string: newString, end: " ** ")
        case .italic:
            writeString = formatString(wrapped: false, start: " * ", string: newString, end: " * ")
        case .h1:
            writeString = formatString(wrapped: false, start: "//: # ", string: newString, end: "\n")
        case .h2:
            writeString = formatString(wrapped: false, start: "//: ## ", string: newString, end: "\n")
        case .h3:
            writeString = formatString(wrapped: false, start: "//: ### ", string: newString, end: "\n")
        case .bullet:
            writeString = formatString(wrapped: true, start: "* ", string: newString, end: "\n")
        case .num:
            writeString = formatString(wrapped: true, start: "1. ", string: newString, end: "\n")
        default:
            return
        }
        outputString += writeString
       // print(outputString)

        
        let uiRange : UITextRange = textView.selectedTextRange!
        textView.replace(uiRange, withText: "")
        ptr = rangeStart + rangeLength
        fileLength = fileLength - rangeLength
        var rng = NSMakeRange(0, fileLength-1)
        _ = attrString.attributes(at: ptr, effectiveRange: &rng)
        rangeStart = ptr
        rangeLength = rng.length
        self.textView.selectedRange = NSMakeRange(0, rangeLength)
    }
    
    func formatString(wrapped: Bool, start: String, string: String, end: String) -> String {
        var lines = string.components(separatedBy: "\u{2028}")
        if (lines.count == 1) {
            lines = string.components(separatedBy: "\n")
        }
        var outstring = ""
        if (wrapped) {
            outstring += "/*:\n"
        }
        for xx in 1...lines.count {
            let subsc = xx - 1
            outstring = outstring + start + lines[subsc] + end
        }
        if (wrapped) {
            outstring += "*/\n"
        }
        return(outstring)
    }
    
    @IBAction func saveFile(_ sender: Any) {
        //print(outputString)
        fm.saveFile(text: outputString)
    }
}
