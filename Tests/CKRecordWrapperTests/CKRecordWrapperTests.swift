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

let creationDate = Date()
let creationTimeInterval = creationDate.timeIntervalSinceReferenceDate

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
        let query = Person.query(
            .where(\.$name, equalTo: "Jayson")
        )
        XCTAssertEqual(query.predicate.predicateFormat, #"name == "Jayson""#)
    }
    
    func testSystemFieldPredicate() throws {
        let query = Person.query(
            .where(.creationDate, equalTo: creationDate)
        )
        XCTAssertEqual(query.predicate.predicateFormat, #"___createTime == CAST(\#(creationTimeInterval), "NSDate")"#)
    }
    
    func testCompoundPredicate() throws {
        let query = Person.query(
            .where(\.$name, equalTo: "Jayson")
            .and(.where(.creationDate, equalTo: creationDate))
        )
        XCTAssertEqual(query.predicate.predicateFormat, #"name == "Jayson" AND ___createTime == CAST(\#(creationTimeInterval), "NSDate")"#)
    }
    
    // type inference is lost here, that's probably unavoidable
    func testUnifiedPredicates() throws {
        let query = Person.query(
            .where2(\Person.$name, equalTo: "Jayson")
            .and(.where2(CKRecord.TypedSystemFieldKey.creationDate, equalTo: creationDate))
        )
        XCTAssertEqual(query.predicate.predicateFormat, #"name == "Jayson" AND ___createTime == CAST(\#(creationTimeInterval), "NSDate")"#)
    }
}
