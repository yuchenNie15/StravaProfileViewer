//
//  ViewDataState.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

public enum ViewDataState<T: Equatable>: Equatable {
    case loading
    case error(DataLoadingError)
    case dataLoaded(T)
    case empty
}

public extension ViewDataState {
  var isLoading: Bool {
    switch self {
    case .loading: return true
    default: return false
    }
  }

  var isDataLoaded: Bool {
    switch self {
    case .dataLoaded: return true
    default: return false
    }
  }

  var data: T? {
    switch self {
    case let .dataLoaded(data): return data
    default: return .none
    }
  }

  var error: DataLoadingError? {
    switch self {
    case let .error(error): return error
    default: return .none
    }
  }
}


public enum DataLoadingError: Error, Equatable, LocalizedError, Sendable {
  case unknown(String)
  case errorWithStatusCode(Int)
  case badResponse(String?)
  case networkError
}

public extension Error {
    var asDataLoaderError: DataLoadingError {
        // If it's already a DataLoadingError, just return it
        if let dataError = self as? DataLoadingError {
            return dataError
        }
        // Otherwise, wrap it in your unknown case
        return .unknown(self.localizedDescription)
    }
}
