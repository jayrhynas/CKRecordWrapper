import CloudKit

public protocol CKRecordWrapper {
    static var recordType: CKRecord.RecordType { get }
    
    init(_ record: CKRecord) throws
    var record: CKRecord { get }
    
    static func key<V>(for keyPath: KeyPath<Self, CKField<V>>) -> String
}

public extension CKRecordWrapper {
    /// The `CKRecord.ID` of the underlying `CKRecord`
    var id: CKRecord.ID { record.recordID }
    
    init() {
        try! self.init(CKRecord(recordType: Self.recordType))
    }
    
    static func key<V>(for keyPath: KeyPath<Self, CKField<V>>) -> String {
        try! self.init(CKRecord(recordType: self.recordType))[keyPath: keyPath].key
    }
    
    static func validateRecordType(for record: CKRecord) throws {
        if record.recordType != Self.recordType {
            throw CKRecordWrapperError.recordTypeMismatch(
                expected: Self.recordType,
                actual: record.recordType
            )
        }
    }
}

public enum CKRecordWrapperError: Error {
    case recordTypeMismatch(expected: CKRecord.RecordType, actual: CKRecord.RecordType)
    case valueNotFound(name: String)
}


// MARK: - Query Helpers

public extension NSSortDescriptor {
    /// Helper method to create an `NSSortDescriptor` for the given `key`, with `ascending: true`
    static func ascending(_ key: String) -> Self {
        .init(key: key, ascending: true)
    }
    
    /// Helper method to create an `NSSortDescriptor` for the given `key`, with `ascending: false`
    static func descending(_ key: String) -> Self {
        .init(key: key, ascending: false)
    }
}

public extension CKRecordWrapper {
    /// Helper to create a query for this record type
    /// - Parameters:
    ///   - predicate: A `Predicate` to be used for the query. `predicate` will be converted to an `NSPredicate` internally. For more information about allowed predicates, see [Predicate Rules for Query Objects](https://developer.apple.com/documentation/cloudkit/ckquery#1666032)
    ///   - sort: An optional `Array` of `NSSortDescriptors` used to sort the records returned by the query. For more information about allowed sort descriptors, see [CKQuery.sortDescriptors](https://developer.apple.com/documentation/cloudkit/ckquery/1413121-sortdescriptors)
    /// - Returns: A `CKQuery` configured with the given predicate and sort descriptors.
    static func query(_ predicate: CKPredicate<Self>, sort: [NSSortDescriptor]? = nil) -> CKQuery {
        let query = CKQuery(recordType: self.recordType, predicate: predicate.predicate)
        query.sortDescriptors = sort?.map { NSSortDescriptor(key: $0.key, ascending: $0.ascending) }
        return query
    }
}
