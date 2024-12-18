//
//  _GeminiTests+StructuredOutput.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Testing
import Foundation
import _Gemini
import AI

@Suite struct _GeminiStructuredOutputTests {
    @Test func testStructuredMovieReview() async throws {
        let reviewSchema = _Gemini.SchemaObject.object(properties: [
            "title": .string,
            "rating": .number,
            "genres": .array(items: .string),
            "review": .string
        ])
        
        let config = _Gemini.GenerationConfig(
            temperature: 0.7,
            responseMimeType: "application/json",
            responseSchema: .object(properties: [
                "review": reviewSchema
            ])
        )
        
        let messages = [
            _Gemini.Message(
                role: .user,
                content: "Write a review for the movie 'Inception' with a rating from 1-10. Return it as a JSON object."
            )
        ]
        
        let response = try await client.generateContent(
            messages: messages,
            model: .gemini_1_5_pro_latest,
            config: config
        )
        
        dump(response)
        
        // Validate the response
        #expect(!response.text.isEmpty, "Response should not be empty")
        
        // Attempt to parse the response as JSON
        if let jsonData = response.text.data(using: String.Encoding.utf8) {
            do {
                let wrapper = try JSONDecoder().decode(MovieReviewWrapper.self, from: jsonData)
                let review = wrapper.review
                
                // Validate the structured output
                #expect(!review.title.isEmpty, "Movie title should not be empty")
                #expect(review.rating >= 1 && review.rating <= 10, "Rating should be between 1 and 10")
                #expect(!review.genres.isEmpty, "Genres array should not be empty")
                #expect(!review.review.isEmpty, "Review text should not be empty")
                
                print("Parsed review:", review)
            } catch {
                print("JSON parsing error:", error)
                print("Response text:", response.text)
                #expect(false, "Failed to parse JSON response: \(error)")
            }
        } else {
            #expect(false, "Failed to convert response to data")
        }
        
        // Check token usage
        if let usage = response.tokenUsage {
            #expect(usage.prompt > 0, "Prompt tokens should be greater than 0")
            #expect(usage.response > 0, "Response tokens should be greater than 0")
            #expect(usage.total == usage.prompt + usage.response, "Total tokens should equal prompt + response")
        }
        
        // Check finish reason
        #expect(response.finishReason == .stop, "Response should have completed normally")
    }
}

// Response structures
private struct MovieReviewWrapper: Codable {
    let review: MovieReview
}

private struct MovieReview: Codable {
    let title: String
    let rating: Double
    let genres: [String]
    let review: String
}
