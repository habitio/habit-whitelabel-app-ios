//
//  MZKeychain.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 18/12/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import UIKit
import Security

// Identifiers
//let serviceIdentifier = ""
let userAccount = "authenticatedUser"
//let accessGroup = "MySerivice"


let key_vendorId = "key_vendor"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class MZKeychain: NSObject {
    
    /**
     * Exposed methods to perform save and load queries.
     */
    
    public class func saveVendorID(vendorId: String) {
        self.save(key_vendorId, data: vendorId)
    }
    
    public class func loadVendorID() -> String? {
        return self.load(key_vendorId)
    }
    
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func save(_ service: String, data: String) {
        let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    private class func load(_ service: String) -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = String(data: retrievedData as Data, encoding: String.Encoding.utf8)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}
