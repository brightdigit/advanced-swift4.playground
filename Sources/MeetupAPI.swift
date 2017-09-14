import Foundation

public struct MeetupAPI {
  public let apiKey : String
  
  public init (apiKey: String) {
    self.apiKey = apiKey
  }
  
  public struct MissingMeetupAPIKeyError : Error {
    
  }
  
  public static let decoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    return decoder
  }()
  
  public static func getApiKey(fromBundle bundle: Bundle = Bundle.main, withResource resource: String =  "meetup_api_key", andExtension `extension`: String? = nil) throws -> String {
    guard let meetup_api_key_url = bundle.url(forResource: resource, withExtension: `extension`) else {
      throw MissingMeetupAPIKeyError()
    }
    
    return try String(contentsOf: meetup_api_key_url).trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  public func task<T : Request, U : Codable>(withRequest request: T, _ callback: @escaping ((T, Result<U>) -> Void)) -> URLSessionDataTask where T.ResultType == U   {
    let url = request.urlWith(apiKey: self.apiKey)
    
    print("Call URL For \(url)...")
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      print("Completed URL For \(url)...")
      if let error = error {
        callback(request, .error(error))
      } else if let data = data {
        var events : U?
        var actualError : Error?
        do {
          events = try MeetupAPI.decoder.decode(U.self, from: data)
        }
        catch let error {
          actualError = error
        }
        if let events = events {
          callback(request, .result(events))
        } else if let error = actualError {
          callback(request, .error(error))
        } else {
          callback(request, .error(InvalidResultError()))
        }
      } else {
        callback(request, .error(InvalidResultError()))
      }
    }
    task.resume()
    return task
  }
  
  
}
