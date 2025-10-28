//
//  DatabaseManager.swift
//  PokemonBrowser
//
//  Created by macbook on 28/10/25.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?
    
    private let usersTable = Table("users")
    private let id = Expression<Int64>("id")
    private let email = Expression<String>("email")
    private let password = Expression<String>("password")
    
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/pokeapp.sqlite3")
            try createUsersTable()
        } catch {
            print("Database connection error: \(error)")
        }
    }
    
    private func createUsersTable() throws {
        try db?.run(usersTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(email, unique: true)
            table.column(password)
        })
    }
    
    func registerUser(userEmail: String, userPass: String) -> Bool {
        guard let db = db else { return false }
        do {
            let existingUser = try db.scalar(usersTable.filter(email == userEmail).count)
            if existingUser > 0 {
                print("Email already registered")
                return false
            }
            
            let insert = usersTable.insert(email <- userEmail, password <- userPass)
            try db.run(insert)
            return true
        } catch {
            print("Registration error: \(error)")
            return false
        }
    }
    
    func loginUser(userEmail: String, userPass: String) -> Bool {
        guard let db = db else { return false }
        do {
            let query = usersTable.filter(email == userEmail && password == userPass)
            let user = try db.pluck(query)
            return user != nil
        } catch {
            print("Login error: \(error)")
            return false
        }
    }
    
    func getUser(userEmail: String) -> User? {
        guard let db = db else { return nil }
        do {
            if let userRow = try db.pluck(usersTable.filter(email == userEmail)) {
                return User(id: userRow[id], email: userRow[email])
            }
        } catch {
            print("Get user error: \(error)")
        }
        return nil
    }
}

struct User {
    let id: Int64
    let email: String
}
