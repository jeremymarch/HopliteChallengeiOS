//
//  Exercises.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/21/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import Foundation
import UIKit

class Item {
    var author = "";
    var desc = "";
    var tag = [Tag]();
}

class Tag {
    var name = ""
    var count: Int?
}

class Sentence {
    var text = ""
    var number = ""
    var unit = ""
    var note = ""
    var lang = ""
}

class Unit {
    var number = ""
    var note = ""
    var greek = [Sentence]()
    var englishToGreek = [Sentence]()
}

class ExercisesViewController: UIViewController, XMLParserDelegate {
    @IBOutlet weak var textView:UITextView!

    var xmlString = "<items><item><author>Robi</author><description>My article about Olympics</description><tag name = \"Olympics\" count = \"3\"/><tag name = \"Rio\"/></item><item><author>Robi</author><description>I can't wait Spa-Francorchamps!!</description><tag name = \"Formula One\"/><tag name = \"Eau Rouge\" count = \"5\"/></item></items>"
    
    var items = [Item]();
    var item = Item();
    var foundCharacters = "";
    
    var units = [Unit]();
    var unit = Unit();
    var sentence = Sentence()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "HQEx", withExtension: "xml")
        {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        else
        {
            let xmlData = xmlString.data(using: String.Encoding.utf8)!
            let parser = XMLParser(data: xmlData)
            parser.delegate = self
            parser.parse()
        }
        let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        textView.font = greekFont
        textView.isEditable = false
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "tag" {
            let tempTag = Tag();
            if let name = attributeDict["name"] {
                tempTag.name = name;
            }
            if let c = attributeDict["count"] {
                if let count = Int(c) {
                    tempTag.count = count;
                }
            }
            self.item.tag.append(tempTag);
        }
        else if elementName == "s"
        {
            if let u = attributeDict["u"] {
                sentence.unit = u
            }
            if let n = attributeDict["n"] {
                sentence.number = n
                sentence.lang = "Greek"
            }
            if let n = attributeDict["e"] {
                sentence.number = n
                sentence.lang = "English"
            }
            if let n = attributeDict["sub"] {
                sentence.number += n
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string;
    }
    
    //saint dynphanas
    //dicks bar
    //even briars
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "author" {
            self.item.author = self.foundCharacters;
        }
        
        if elementName == "description" {
            self.item.desc = self.foundCharacters;
        }
        /*
        if elementName == "s" {
            self.item.desc = self.foundCharacters;
        }
        */
        if elementName == "g" {
            self.sentence.text = self.foundCharacters
            
            let tempSentence = Sentence()
            tempSentence.unit = self.sentence.unit
            tempSentence.number = self.sentence.number
            tempSentence.lang = self.sentence.lang
            tempSentence.text = self.sentence.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            self.unit.greek.append(tempSentence)
        }
        if elementName == "e" {
            self.sentence.text = self.foundCharacters
            
            let tempSentence = Sentence()
            tempSentence.unit = self.sentence.unit
            tempSentence.number = self.sentence.number
            tempSentence.lang = self.sentence.lang
            tempSentence.text = self.sentence.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            self.unit.greek.append(tempSentence)
        }
        if elementName == "item" {
            let tempItem = Item();
            tempItem.author = self.item.author;
            tempItem.desc = self.item.desc;
            tempItem.tag = self.item.tag;
            self.items.append(tempItem);
            self.item.tag.removeAll();
        }
        self.foundCharacters = ""
        self.sentence.lang = ""
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        /*
        var s = ""
        for item in self.items {
            s += "\(item.author)\n\(item.desc)"
            for tags in item.tag {
                if let count = tags.count {
                    s += "\(tags.name), \(count)"
                } else {
                    s += "\(tags.name)"
                }
            }
            s += "\n"
            print(s)
        }
         */
        var s = ""
        for se in self.unit.greek
        {
            s += se.unit + "." + se.number + " " + se.lang + "\n" + se.text + "\n\n"
        }
        print(s)
        textView.text = s
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}
