//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

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
