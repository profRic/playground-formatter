//
//  rtfView.swift
//  TestRTF
//
//  Created by Ric Telford on 3/10/17.
//  Copyright © 2017 Ric Telford. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class rtfView: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any!) -> Bool {
       
        if (action == #selector(textItem(_:))) || (action == #selector(h1Item(_:))) || (action == #selector(h2Item(_:))) || (action == #selector(h3Item(_:))) || (action == #selector(boldItem(_:))) || (action == #selector(italicItem(_:))) || (action == #selector(bulletItem(_:))) || (action == #selector(numListItem(_:))) {
            return true
        } else {
            return false
        }
        
    }
    
    func textItem(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.text)
    }
    func boldItem(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.bold)
    }
    func italicItem(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.italic)
    }
    func h1Item(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.h1)
    }
    func h2Item(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.h2)
    }
    func h3Item(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.h3)
    }
    func bulletItem(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.bullet)
    }
    func numListItem(_ sender: UIMenuController){
        let delg = parentViewController as! ViewController
        delg.saveItem(value: markupType.num)
    }
    
}
