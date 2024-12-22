//
//  _GeminiTests+FineTuning.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Testing
import Foundation
import _Gemini
import AI

@Suite struct _GeminiModelTuningTests {
    // Test case structure
    struct TestCase {
        let input: String
        let expectedOutput: String
    }
    
    // Keep existing examples and config
    static let examples = [
        // Numeric inputs
        _Gemini.FineTuningExample(textInput: "1", output: "2"),
        _Gemini.FineTuningExample(textInput: "2", output: "3"),
        _Gemini.FineTuningExample(textInput: "3", output: "4"),
        _Gemini.FineTuningExample(textInput: "4", output: "5"),
        _Gemini.FineTuningExample(textInput: "9", output: "10"),
        _Gemini.FineTuningExample(textInput: "10", output: "11"),
        
        // Text inputs
        _Gemini.FineTuningExample(textInput: "one", output: "two"),
        _Gemini.FineTuningExample(textInput: "two", output: "three"),
        _Gemini.FineTuningExample(textInput: "three", output: "four"),
        _Gemini.FineTuningExample(textInput: "nine", output: "ten"),
        _Gemini.FineTuningExample(textInput: "ten", output: "eleven"),
    ]
    
    static let tuningConfig = _Gemini.TuningConfig(
        displayName: "number increment model",
        baseModel: .gemini_1_5_flash,
        tuningTask: .init(
            hyperparameters: .init(
                batchSize: 4,
                learningRate: 0.001,
                epochCount: 10
            ),
            trainingData: .init(
                examples: .init(examples: examples)
            )
        )
    )
    
    @Test func testCreateTunedModel() async throws {
        print("\nStarting model tuning...")
        let operation = try await client.createTunedModel(config: Self.tuningConfig)
        
        print("\nInitial operation response:",
              String(data: try JSONEncoder().encode(operation), encoding: .utf8) ?? "")
        
        #expect(!operation.name.isEmpty)
        #expect(operation.metadata != nil)
        
        if let totalSteps = operation.metadata?.totalSteps {
            print("\nTotal tuning steps:", totalSteps)
        }
        
        print("\nWaiting for model to become active...")
        let completedModel = try await client.waitForTuningCompletion(
            operation: operation
        )
        
        print("\nFinal model state:", completedModel.state.rawValue)
        print("Model details:",
              String(data: try JSONEncoder().encode(completedModel), encoding: .utf8) ?? "")
        
        #expect(completedModel.state == .active)
        
        UserDefaults.standard.set(completedModel.name, forKey: "lastTunedModelName")
    }
    
    @Test func testGenerateWithTunedModel() async throws {
        guard let modelName = UserDefaults.standard.string(forKey: "lastTunedModelName") else {
            throw TestError.noModelAvailable
        }
        
        print("\nUsing model:", modelName)
        
        let testCases = [
            // Test numeric inputs
            TestCase(input: "5", expectedOutput: "6"),
            TestCase(input: "10", expectedOutput: "11"),
            TestCase(input: "99", expectedOutput: "100"),
            TestCase(input: "-3", expectedOutput: "-2"),
            
            // Test text inputs
            TestCase(input: "ten", expectedOutput: "eleven"),
            TestCase(input: "twenty", expectedOutput: "twenty one"),
            TestCase(input: "thirty", expectedOutput: "thirty one")
        ]
        
        let config = _Gemini.GenerationConfiguration(
            maxOutputTokens: 100,
            temperature: 0.0,  // Use 0 temperature for deterministic outputs
            topP: 1.0,
            topK: 1
        )
        
        var successCount = 0
        var failureCount = 0
        
        for testCase in testCases {
            print("\n=== Testing input:", testCase.input, "===")
            do {
                let response = try await client.generateWithTunedModel(
                    modelName: modelName,
                    input: testCase.input,
                    config: config
                )
                
                let output = response.text.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Model output:", output)
                print("Expected output:", testCase.expectedOutput)
                
                if let usage = response.tokenUsage {
                    print("Token usage - Prompt:", usage.prompt,
                          "Response:", usage.response,
                          "Total:", usage.total)
                }
                
                #expect(!output.isEmpty, "Output should not be empty")
                
                if output == testCase.expectedOutput {
                    print("✅ Output matches expected")
                    successCount += 1
                } else {
                    print("⚠️ Output differs from expected:")
                    print("  Actual:", output)
                    print("  Expected:", testCase.expectedOutput)
                    failureCount += 1
                }
            } catch {
                print("❌ Error testing input '\(testCase.input)':", error)
                failureCount += 1
            }
        }
        
        print("\nTest Summary:")
        print("Successes:", successCount)
        print("Failures:", failureCount)
        print("Total cases:", testCases.count)
        
        #expect(successCount > 0, "At least one test should pass")
    }
    
    private enum TestError: Error {
        case missingAPIKey
        case noModelAvailable
    }
}
