//
// Copyright (c) Vatsal Manot
//

import Foundation

extension Perplexity.APISpecification.RequestBodies {
    /// https://docs.perplexity.ai/reference/post_chat_completions
    public struct ChatCompletions: Codable, Hashable, Sendable {
        /// Default: llama-3-sonar-small-32k-online
        public var model: Perplexity.Model
        
        /// A list of messages comprising the conversation so far.
        public var messages: [Perplexity.ChatMessage]
        
        /// The amount of randomness in the response, valued between 0 inclusive and 2 exclusive. Higher values are more random, and lower values are more deterministic. Defaults to 0.2
        public var temperature: Double?
        
        /// The nucleus sampling threshold, valued between 0 and 1 inclusive. For each subsequent token, the model considers the results of the tokens with top_p probability mass. We recommend either altering top_k or top_p, but not both. Defaults to 0.9
        public var topP: Double?
        
        /// The number of tokens to keep for highest top-k filtering, specified as an integer between 0 and 2048 inclusive. If set to 0, top-k filtering is disabled. We recommend either altering top_k or top_p, but not both.
        public var topK: Int?
        
        /// The maximum number of completion tokens returned by the API. The total number of tokens requested in max_tokens plus the number of prompt tokens sent in messages must not exceed the context window token limit of model requested. If left unspecified, then the model will generate tokens until either it reaches its stop token or the end of its context window.
        public var maxTokens: Int?
        
        /// Determines whether or not a request to an online model should return citations. Citations are in closed beta access. To gain access, apply at https://perplexity.typeform.com/to/j50rnNiB
        public var returnCitations: Bool?
        
        /// Determines whether or not a request to an online model should return images. Images are in closed beta access. To gain access, apply at https://perplexity.typeform.com/to/j50rnNiB
        public var returnImages: Bool?
        
        /// Determines whether or not to incrementally stream the response with server-sent events with content-type: text/event-stream.
        public var stream: Bool?
        
        /// A value between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics. Incompatible with frequency_penalty.
        public var presencePenalty: Double?
        
        /// A multiplicative penalty greater than 0. Values greater than 1.0 penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim. A value of 1.0 means no penalty. Incompatible with presence_penalty.
        public var frequencyPenalty: Double?
    }
}
