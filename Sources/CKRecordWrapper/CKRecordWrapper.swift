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
