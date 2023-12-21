//
//  File.swift
//  
//
//  Created by Jayson Rhynas on 2023-12-21.
//

import Foundation
import CloudKit

public class CKPredicate<T: CKRecordWrapper> {
    public let predicate: NSPredicate
    
    public init(_ predicate: NSPredicate) {
        self.predicate = predicate
    }
    
    public static var all: CKPredicate {
        CKPredicate(NSPredicate(format: "TRUEPREDICATE"))
    }
    
    public func and(_ other: CKPredicate<T>) -> CKPredicate<T> {
        CKPredicate(NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, other.predicate]))
    }
    
    public func or(_ other: CKPredicate<T>) -> CKPredicate<T> {
        CKPredicate(NSCompoundPredicate(orPredicateWithSubpredicates: [self.predicate, other.predicate]))
    }
}

// MARK: - CKField key paths
public extension CKPredicate {
    private convenience init<V>(_ keyPath: KeyPath<T, CKField<V>>, _ op: String, _ value: V) {
        let key = T.key(for: keyPath)
        self.init(NSPredicate(format: "%K \(op) %@", argumentArray: [key, value]))
    }
    
    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, lessThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(keyPath, "<", value)
    }

    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, lessThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(keyPath, "<=", value)
    }

    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, greaterThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(keyPath, ">", value)
    }

    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, greaterThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(keyPath, ">=", value)
    }

    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, equalTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(keyPath, "==", value)
    }
    
    static func `where`(_ keyPath: KeyPath<T, CKField<CKRecord.Reference?>>, equalTo value: CKRecord.ID) -> CKPredicate {
        CKPredicate(keyPath, "==", CKRecord.Reference(recordID: value, action: .none))
    }

    static func `where`<V>(_ keyPath: KeyPath<T, CKField<V>>, notEqualTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(keyPath, "!=", value)
    }

    static func `where`(_ keyPath: KeyPath<T, CKField<String>>, beginsWith value: String) -> CKPredicate {
        CKPredicate(keyPath, "BEGINSWITH", value)
    }
}

// MARK: - TypedSystemField
extension CKRecord {
    public struct TypedSystemFieldKey<Value> {
        typealias SystemKey = CKRecord.SystemFieldKey
        
        let key: CKRecord.FieldKey
    }
}

public extension CKRecord.TypedSystemFieldKey where Value == CKRecord.ID {
    static let recordID                 = Self.init(key: Self.SystemKey.recordID)
    static let creatorUserRecordID      = Self.init(key: Self.SystemKey.creatorUserRecordID)
    static let lastModifiedUserRecordID = Self.init(key: Self.SystemKey.lastModifiedUserRecordID)
}

public extension CKRecord.TypedSystemFieldKey where Value == Date {
    static let creationDate     = Self.init(key: Self.SystemKey.creationDate)
    static let modificationDate = Self.init(key: Self.SystemKey.modificationDate)
}

public extension CKRecord.TypedSystemFieldKey where Value == CKRecord.Reference {
    static let parent = Self.init(key: Self.SystemKey.parent)
    static let share  = Self.init(key: Self.SystemKey.share)
}

public extension CKPredicate {
    private convenience init<V>(_ key: CKRecord.TypedSystemFieldKey<V>, _ op: String, _ value: V) {
        self.init(NSPredicate(format: "%K \(op) %@", argumentArray: [key.key, value]))
    }
    
    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, lessThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, "<", value)
    }

    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, lessThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, "<=", value)
    }

    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, greaterThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, ">", value)
    }

    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, greaterThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, ">=", value)
    }

    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, equalTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(key, "==", value)
    }

    static func `where`(_ key: CKRecord.TypedSystemFieldKey<CKRecord.Reference?>, equalTo value: CKRecord.ID) -> CKPredicate {
        CKPredicate(key, "==", CKRecord.Reference(recordID: value, action: .none))
    }

    static func `where`<V>(_ key: CKRecord.TypedSystemFieldKey<V>, notEqualTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(key, "!=", value)
    }
}

// MARK: - Attempt at unifying

public protocol StringKeyConvertible<Value> {
    associatedtype Value
    var stringKey: String { get }
}

extension CKRecord.TypedSystemFieldKey: StringKeyConvertible {
    public var stringKey: String { key }
}

extension CKField: StringKeyConvertible {
    public var stringKey: String { key }
}

extension KeyPath: StringKeyConvertible where Root: CKRecordWrapper, Value: StringKeyConvertible {
    public typealias Value = Value.Value
    public var stringKey: String {
        Root()[keyPath: self].stringKey
    }
}

public extension CKPredicate {
    private convenience init<V>(_ key: any StringKeyConvertible<V>, _ op: String, _ value: V) {
        self.init(NSPredicate(format: "%K \(op) %@", argumentArray: [key.stringKey, value]))
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, lessThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, "<", value)
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, lessThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, "<=", value)
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, greaterThan value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, ">", value)
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, greaterThanOrEqualTo value: V) -> CKPredicate where V: Comparable {
        CKPredicate(key, ">=", value)
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, equalTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(key, "==", value)
    }
    
    static func where2(_ key: any StringKeyConvertible<CKRecord.Reference?>, equalTo value: CKRecord.ID) -> CKPredicate {
        CKPredicate(key, "==", CKRecord.Reference(recordID: value, action: .none))
    }
    
    static func where2<V>(_ key: any StringKeyConvertible<V>, notEqualTo value: V) -> CKPredicate where V: Equatable {
        CKPredicate(key, "!=", value)
    }
    
    static func where2(_ key: any StringKeyConvertible<String>, beginsWith value: String) -> CKPredicate {
        CKPredicate(key, "BEGINSWITH", value)
    }
}
