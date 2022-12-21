//
//  File.swift
//  
//
//  Created by JongHo Park on 2022/08/30.
//

import Foundation

extension SecretInfoKeychain {
    public enum KeyChainError: Error, LocalizedError {
        case stringToDataConversionError
        case dataToStringConversionError
        case unknownError(message: String)
        case dataNotExists

        public var errorDescription: String? {
            switch self {
            case .stringToDataConversionError:
                return NSLocalizedString("String to data conversion error", comment: "")
            case .dataToStringConversionError:
                return NSLocalizedString("Data to string conversion error", comment: "")
            case .unknownError(let message):
                return NSLocalizedString("Unknown Error, \(message)", comment: "")
            case .dataNotExists:
                return NSLocalizedString("Data is not exists", comment: "")
            }
        }
    }
}
