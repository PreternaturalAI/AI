//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import OpenAI
import XCTest

final class FileTests: XCTestCase {
    func createTestFile<T: DataCodableWithDefaultStrategies>(
        named filename: String?,
        data value: T
    ) throws -> URL {
        let fileExtension: String
        
        switch type(of: value) {
            case is String.Type:
                fileExtension = "txt"
            case is JSON.Type:
                fileExtension = "json"
            default:
                fatalError()
        }
        
        let url = URL.temporaryDirectory
            .appending(.directory("OpenAI-Tests"))
            .appending(filename ?? UUID().uuidString)
            .appendingPathExtension(fileExtension)
        
        let data: Data = try value.data()
        
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        try data.write(to: url)
        
        return url
    }
    
    func testUploadFile() async throws {
        let stringFile = try createTestFile(named: "foo", data: "Hello, World!")
        
        let file = try await client.uploadFile(stringFile)
        
        print(file)
    }
    
    func testListFiles() async throws {
        try await testUploadFile()
        
        let files = try await client.listFiles(purpose: .assistants)
        
        XCTAssertTrue(files.data.count != 0)
        
        print(files)
    }
    
    func testDeletingFiles() async throws {
        try await testUploadFile()
        
        var files = try await client.listFiles(purpose: .assistants)
        
        let filesToDelete: Set<OpenAI.File.ID> = Set(files.filter({ $0.filename == "foo.txt" }).map(\.id))
        
        for file in filesToDelete {
            let deletionStatus = try await client.deleteFile(file)
            
            XCTAssertEqual(deletionStatus.id, file.id)
        }
        
        files = try await client.listFiles(purpose: .assistants)
        
        XCTAssertFalse(Set(files.map(\.id)).intersects(with: filesToDelete))
    }
}
