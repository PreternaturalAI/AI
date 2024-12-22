//
//  ChatGroup.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientChatGroupTests: XCTestCase {
    
    func testListChatGroups() async throws {
        let groups = try await client.listChatGroups()
        XCTAssertNotNil(groups)
    }
    
    func testGetChatGroup() async throws {
        let group = try await client.getChatGroup(id: "test-id")
        XCTAssertNotNil(group)
    }
    
    func testListChatGroupEvents() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetChatGroupAudio() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
