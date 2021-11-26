//
//  Vocabalary.swift
//  mindsUnlimited
//
//  Created by IPS on 03/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation
class Vocabulary:NSObject{
    static func getWordFromKey(key:String)->String{
        return getWordFromLocalPlist(key: key)//key.removeWhiteSpaces())
    }
    
    
    private static func getWordFromLocalPlist(key:String)->String{
        
        var selectedLanguage = String.getSelectedLanguage()
        
        if selectedLanguage == "1" {
            selectedLanguage = "English"
        } else if selectedLanguage == "2" {
            selectedLanguage = "SwedishVocabalary"
        } else if selectedLanguage == "3" {
            selectedLanguage = "Greek"
        } else if selectedLanguage == "4" {
            selectedLanguage = "Norway"
        } else if selectedLanguage == "5" {
            selectedLanguage = "Portuguese"
        } else if selectedLanguage == "6" {
            selectedLanguage = "Spanish"
        } else {
            selectedLanguage = "EnglishVocabalary"
        }
        
        var vocabDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "plist") {
            vocabDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let vocabsDictnary1 = vocabDictionary,let value = vocabsDictnary1[key] as? String{
            return value
        }
        return key.replacingOccurrences(of: "_", with: " ")
        
    }
    
}
