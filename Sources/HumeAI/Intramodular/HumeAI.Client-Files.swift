//
//  HumeAI.Client-Files.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listFiles() async throws -> [HumeAI.APISpecification.ResponseBodies.File] {
        let response = try await run(\.listFiles)
        return response.files
    }
    
    public func uploadFile(
        data: Data,
        name: String,
        metadata: [String: String]? = nil
    ) async throws -> HumeAI.APISpecification.ResponseBodies.File {
        let input = HumeAI.APISpecification.RequestBodies.UploadFileInput(file: data, name: name, metadata: metadata)
        return try await run(\.uploadFile, with: input)
    }
    
    public func deleteFile(id: String) async throws {
        try await run(\.deleteFile, with: id)
    }
}
