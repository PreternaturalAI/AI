//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension OpenAI.Client {
    /// The format in which the generated images are returned.
    public enum ImageResponseFormat: String, Codable, CaseIterable {
        /// URLs are only valid for 60 minutes after the image has been generated.
        case ephemeralURL = "url"
        case base64JSON
    }
    
    /// Create an image using DALL-E.
    ///
    /// The maximum length for the prompt is `1000` characters for `dall-e-2` and `4000` characters for `dall-e-3`.
    public func createImage(
        prompt: String,
        responseFormat: ImageResponseFormat = .ephemeralURL,
        numberOfImages: Int = 1,
        quality: OpenAI.Image.Quality = .standard,
        size: OpenAI.Image.Size = .w1024h1024,
        style: OpenAI.Image.Style = .vivid,
        user: String? = nil
    ) async throws -> OpenAI.List<OpenAI.Image> {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateImage(
            prompt: prompt,
            model: .dalle3,
            responseFormat: responseFormat,
            numberOfImages: numberOfImages,
            quality: quality,
            size: size,
            style: style,
            user: user
        )
        
        let response = try await run(\.createImage, with: requestBody)
        
        return response
    }
}
