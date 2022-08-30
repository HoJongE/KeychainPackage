//
//  File.swift
//  
//
//  Created by JongHo Park on 2022/08/30.
//

import Foundation

public enum KeyChainError: Error {
    case stringToDataConversionError
    case dataToStringConversionError
    case unknownError(message: String)
}

extension KeyChainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .stringToDataConversionError:
            return NSLocalizedString("String to data conversion error", comment: "")
        case .dataToStringConversionError:
            return NSLocalizedString("Data to string conversion error", comment: "")
        case .unknownError(let message):
            return NSLocalizedString("Unknown Error, \(message)", comment: "")
        }
    }
}
