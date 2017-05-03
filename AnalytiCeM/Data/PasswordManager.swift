//
//  PasswordManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 03/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import CryptoSwift

import Foundation

final class PasswordManager: NSObject {
    
    // MARK: - Properties
    
    let nbIterations: Int = 4096
    
    // shared instance
    static let shared: PasswordManager = PasswordManager()
    
    // MARK: - Init
    private override init() {
        super.init()
    }
    
    public func createHash(password: String) -> (salt: String, passwordHashed: String)? {
        
        var salt: String = ""
        var passwordCrypted: String = ""
        
        do {
        
            let passwordArray: Array<UInt8> = Array(password.utf8)
        
            // generated unique salt
            salt = UUID().uuidString
            let salted: Array<UInt8> = Array(salt.utf8)
        
            let passwordValue = try PKCS5.PBKDF2(password: passwordArray, salt: salted, iterations: nbIterations, variant: .sha512).calculate()
        
            // export has readable string
            passwordCrypted = passwordValue.toHexString()
            
            return (salt, passwordCrypted)
            
        } catch _ {
            
            return nil
            
        }
    }
    
    public func verifyPassword(tryPassword password: String, salt: String, correctPassword: String) -> Bool? {
        
        let tryPassword: Array<UInt8> = Array(password.utf8)
        let salted: Array<UInt8> = Array(salt.utf8)
        
        do {
        
            let passwordCryptedRaw = try PKCS5.PBKDF2(password: tryPassword, salt: salted, iterations: nbIterations, variant: .sha512).calculate()
        
            // export has readable string
            let passwordCrypted = passwordCryptedRaw.toHexString()
            
            // compare
            return (passwordCrypted == correctPassword)
        
        } catch _ {
            
            return nil
            
        }
        
    }
    
}
