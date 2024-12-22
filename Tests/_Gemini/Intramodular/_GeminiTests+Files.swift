//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation
import Testing
import _Gemini

@Suite struct GeminiFileTests {
    
    private let fileURL = URL(string: "https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png")!
    private var fileData: Data? = nil
    private var fileName: _Gemini.File.Name? = nil
    
    @Test mutating func testUploadFileFromData() async throws {
        let file: _Gemini.File = try await uploadFile()
        
        print(file)
        #expect(file.name.isNotNil)
        #expect(((file.name?.rawValue.starts(with: "files/")) == true))
    }
    
    @Test mutating func testUploadFileFromRemoteURL() async throws {
        
        let file = try await client.uploadFile(
            from: fileURL,
            mimeType: .custom("image/png"),
            displayName: UUID().uuidString
        )
        
        print(file)
        #expect(file.name.isNotNil)
        #expect(((file.name?.rawValue.starts(with: "files/")) == true))
    }
    
    @Test mutating func testUploadFileFromLocalURL() async throws {
        
        let fileData = try await downloadFile(from: fileURL)
        let fileName = UUID().uuidString + ".png"
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try fileData.write(to: fileURL)
        
        let file = try await client.uploadFile(
            from: fileURL,
            mimeType: .custom("image/png"),
            displayName: UUID().uuidString
        )
        
        print(file)
        #expect(file.name.isNotNil)
        #expect(((file.name?.rawValue.starts(with: "files/")) == true))
    }
    
    @Test mutating func testGetFile() async throws {

        if fileName == nil {
            fileName = try await uploadFile().name
        }

        guard let fileName = fileName else {
            #expect(Bool(false), "The file name is invalid")
            
            return
        }

        let file: _Gemini.File = try await client.getFile(name: fileName)
        #expect(file.name?.rawValue == fileName.rawValue)
    }
    
    @Test mutating func testListFiles() async throws {
        let file = try await uploadFile()
        let fileList: _Gemini.FileList = try await client.listFiles()
        let files: [_Gemini.File] = fileList.files
        
        guard let fileName = file.name else {
            #expect(Bool(false), "The uploaded file has no valid name.")
            
            return
        }
        
        let uploadedFileIsPresent = files.contains { $0.name! == fileName }
        #expect(uploadedFileIsPresent, "Expected the newly uploaded file to be in the returned file list.")
    }
    
    @Test mutating func testDeleteFile() async throws {
        let uploadedFile = try await uploadFile()
        let file: _Gemini.File = try await client.getFile(name: uploadedFile.name!)
        
        try await client.deleteFile(fileURL: file.uri)
        do {
            let _ = try await client.getFile(name: uploadedFile.name!)
            #expect(Bool(false), "Expected getFile to throw when fetching a deleted file, but it succeeded.")
        } catch {
            #expect(Bool(true), "getFile threw an error, as expected, when trying to retrieve a deleted file.")
        }
    }
}

extension GeminiFileTests {
    
    private mutating func uploadFile() async throws -> _Gemini.File {
        let data = try await downloadFile(from: fileURL)
        
        let file = try await client.uploadFile(
            from: data,
            mimeType: .custom("image/png"),
            displayName: UUID().uuidString
        )
        
        self.fileName = file.name
        
        return file
    }
    
    private func downloadFile(from url: URL) async throws -> Data {
        if let data = fileData {
            return data
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw _Gemini.APIError.unknown(message: "Failed to download file from URL")
        }
        
        return data
    }
}

