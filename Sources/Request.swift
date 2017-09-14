import Foundation

public protocol Request {
  associatedtype ResultType
  func urlWith(apiKey: String) -> URL
}
