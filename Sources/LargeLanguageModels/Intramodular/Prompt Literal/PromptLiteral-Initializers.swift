//
// Copyright (c) Vatsal Manot
//

import FoundationX
import Swallow
@_spi(Internal) import SwiftUIX

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || os(watchOS)
extension PromptLiteral {
    init(
        _imageOrImageURL image: Either<SwiftUIX._AnyImage, URL>
    ) throws {
        let payload: PromptLiteral.StringInterpolation.Component.Payload
        
        switch image {
            case .left(let image):
                payload = .image(.image(image))
            case .right(let imageURL):
                payload = .image(.url(imageURL as URL))
        }
        
        self.init(stringInterpolation: .init(payload: payload))
        
        if _isDebugAssertConfiguration {
            let isEmpty = try self.isEmpty
            
            assert(!isEmpty)
        }
    }
        
    public init(
        imageURL url: URL
    ) throws {
        try self.init(_imageOrImageURL: .right(url))
    }
    
    public init(
        imageURL url: String
    ) throws {
        try self.init(imageURL: URL(string: url).unwrap())
    }
    
    public init(
        image: SwiftUIX._AnyImage
    ) throws {
        try self.init(_imageOrImageURL: .left(image))
    }
    
    public init(image: SwiftUIX.AppKitOrUIKitImage) throws {
        try self.init(image: SwiftUIX._AnyImage(image))
    }

    public init(
        image: SwiftUIX._AnyImage.Name
    ) throws {
        try self.init(image: _AnyImage(named: image))
    }
    
    public init(
        image: String,
        in bundle: Bundle?
    ) throws {
        try self.init(
            image: try AppKitOrUIKitImage(named: .bundleResource(image, in: bundle)).unwrap()
        )
    }
}
#endif
