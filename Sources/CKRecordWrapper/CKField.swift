//
//  File.swift
//  
//
//  Created by Jayson Rhynas on 2023-12-21.
//

import CloudKit

extension Optional: CKRecordValueProtocol where Wrapped: CKRecordValueProtocol {}

/// A property wrapper that proxies access to a field in a `CKRecord`
///
/// - Parameters:
///   - wrappedValue: Used as a default value when the specified field does not exist in the record (or exists but is the wrong type)
///   - key: The key to look up in the record
@propertyWrapper
public struct CKField<Value: CKRecordValueProtocol> {
    public static subscript<T: CKRecordWrapper>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            return (instance.record[storage.key] as? Value) ?? storage.defaultValue
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            
            if case let .some(value) = (newValue as? Optional<CKRecordValue>) {
                instance.record[storage.key] = value
            } else {
                instance.record[storage.key] = nil
            }
        }
    }
    
    @available(*, unavailable,
        message: "This property wrapper can only be applied to classes"
    )
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    let key: String
    let defaultValue: Value
    
    init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    init<T>(_ key: String) where Value == Optional<T> {
        self.init(wrappedValue: nil, key)
    }
    
    public var projectedValue: Self {
        self
    }
}

