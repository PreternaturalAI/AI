//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {
    public protocol CompletionParameters: Hashable, Sendable {
        
    }

    public enum TokenLimit: Hashable, Sendable {
        case max
        case fixed(Int)
        
        public var fixedValue: Int? {
            guard case .fixed(let value) = self else {
                return nil
            }
            
            return value
        }
    }
    
    /// Either temperature or top-p should be used, both cannot be specified at the same time.
    public enum TemperatureOrTopP: Hashable, Sendable {
        case temperature(Double)
        case topProbabilityMass(Double)
        
        public var temperature: Double? {
            guard case .temperature(let value) = self else {
                return nil
            }
            
            return value
        }
        
        public var topProbabilityMass: Double? {
            guard case .topProbabilityMass(let value) = self else {
                return nil
            }
            
            return value
        }
    }
}
