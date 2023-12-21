import XCTest
@testable import CKRecordWrapper
import CloudKit

final class Person: CKRecordWrapper {
    static let recordType = "Person"
    
    let record: CKRecord
    
    init(_ record: CKRecord) throws {
        try Self.validateRecordType(for: record)
        self.record = record
    }
    
    @CKField("name")
    var name: String?
}

final class CKRecordWrapperTests: XCTestCase {
    func testWrap() throws {
        let record = CKRecord(recordType: "Person")
        XCTAssertNoThrow(try Person(record))
        
        let badRecord = CKRecord(recordType: "Address")
        XCTAssertThrowsError(try Person(badRecord))
    }
    
    func testField() throws {
        let person = Person()
        
        person.name = "Jayson"
        
        XCTAssertEqual(person.record["name"], "Jayson")
    }
    
    func testFieldPredicate() throws {
        let pred = CKPredicate<Person>.where(\.$name, equalTo: "Jayson")
        XCTAssertEqual(pred.predicate.predicateFormat, #"name == "Jayson""#)
    }
    
    func testSystemFieldPredicate() throws {
        let userId = CKRecord.ID(recordName: "_4e9be40733e241d8b1a5c38b5e12122d")
        let pred = CKPredicate<Person>.where(.creatorUserRecordID, equalTo: userId)
        XCTAssertEqual(pred.predicate.predicateFormat, "___createdBy == \(userId)")
    }
}
