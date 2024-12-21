//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

final class HumeAIClientFileTests: XCTestCase {
    
    func testListFiles() async throws {
        let files = try await client.listFiles()
        XCTAssertNotNil(files)
    }
    
    func testUploadFile() async throws {
        let file = try await client.uploadFile(data: Data(), name: "test.txt")
        XCTAssertNotNil(file)
    }
    
    func testDeleteFile() async throws {
        try await client.deleteFile(id: "test-id")
    }
    
    func testGetFile() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateFileName() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetFilePredictions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
