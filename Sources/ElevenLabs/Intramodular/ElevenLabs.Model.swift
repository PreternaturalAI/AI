//
// Copyright (c) Vatsal Manot
//

import Foundation

extension ElevenLabs {
    public enum Model: String, Codable, Sendable {
        // Information about each model here: https://help.elevenlabs.io/hc/en-us/articles/17883183930129-What-models-do-you-offer-and-what-is-the-difference-between-them
        // Using cutting-edge technology, this is a highly optimized model for real-time applications that require very low latency, but it still retains the fantastic quality offered in our other models. Even if optimized for real-time and more conversational applications, we still recommend testing it out for other applications as it is very versatile and stable.
        case TurboV2 = "eleven_turbo_v2"
        /// This model is a powerhouse, excelling in stability, language diversity, and accuracy in replicating accents and voices. Its speed and agility are remarkable considering its size. Multilingual v2 supports a 28 languages.
        case MultilingualV2 = "eleven_multilingual_v2"
        /// This model was created specifically for English and is the smallest and fastest model we offer. As our oldest model, it has undergone extensive optimization to ensure reliable performance but it is also the most limited and generally the least accurate.
        case EnglishV1 = "eleven_monolingual_v1"
        /// Taking a step towards global access and usage, we introduced Multilingual v1 as our second offering. Has been an experimental model ever since release. To this day, it still remains in the experimental phase.
        case MultilingualV1 = "eleven_multilingual_v1"
    }
}
