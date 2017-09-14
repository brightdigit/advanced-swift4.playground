import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

public struct InvalidResultError : Error {
  
}


public enum Result<T> {
  case error(Error), result(T)
}

public struct MeetupEvent : Codable {
  public let time:Date
  public let name:String
  public let description:String
  public let link:URL
  public let id:String
}

public struct MeetupPhoto : Codable {
  public let id: Int
  public let photo_link: URL
  public let thumb_link: URL
}

public struct MeetupMember : Codable {
  public let id: Int
  public let name : String
  public let photo : MeetupPhoto
}

public struct MeetupGroup : Codable {
  public let id: Int
  public let name: String
  public let link: URL
  public let description: String
  public let created: Date
  public let organizer: MeetupMember
  public let urlname: String
  
}

public typealias MeetupGroupEvents = (group: MeetupGroup, events : [MeetupEvent])


guard let meetup_api_key_url = Bundle.main.url(forResource: "meetup_api_key", withExtension: nil) else {
  assertionFailure("No meetup api key file")
  PlaygroundPage.current.finishExecution()
}

guard let apiKey = try? String(contentsOf: meetup_api_key_url).trimmingCharacters(in: .whitespacesAndNewlines) else {
  assertionFailure("No MEETUP_API_KEY set")
  PlaygroundPage.current.finishExecution()
}

public protocol Request {
  associatedtype ResultType
  func urlWith(apiKey: String) -> URL
}



public struct FetchGroupEventsRequest : Request {
  public typealias ResultType = [MeetupEvent]
  
  public let group : MeetupGroup
  
  public func urlWith(apiKey: String) -> URL {
    let urlString = "https://api.meetup.com/\(self.group.urlname)/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration"
    return URL(string: urlString)!
  }
}

public struct FindGroupsByTextRequest : Request {
  public typealias ResultType = [MeetupGroup]
  
  public let text : String
  public let radius : Int
  public let groupEventMaxCount : Int
  
  public func urlWith(apiKey: String) -> URL {
    let urlString = "https://api.meetup.com/find/groups?&sign=true&photo-host=public&upcoming_events=true&text=\(self.text)&radius=\(self.radius)&page=\(self.groupEventMaxCount)&sign=true&key=\(apiKey)"
    return URL(string: urlString)!
  }
}

public struct MeetupAPI {
  public let apiKey : String
  
  public static let decoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    return decoder
  }()
  
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
  
//  public func fetchEvents (forGroup group: MeetupGroup, callback: @escaping ((MeetupGroup, Result<[MeetupEvent]>) -> Void)) -> URLSessionDataTask {
//    let urlString = "https://api.meetup.com/\(group.urlname)/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration"
//    let url = URL(string: urlString)!
//    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
//      if let error = error {
//        callback(group, .error(error))
//      } else if let data = data {
//        var events : [MeetupEvent]?
//        var actualError : Error?
//        do {
//          events = try MeetupAPI.decoder.decode([MeetupEvent].self, from: data)
//        }
//        catch let error {
//          actualError = error
//        }
//        if let events = events {
//          callback(group, .result(events))
//        } else if let error = actualError {
//          callback(group, .error(error))
//        } else {
//          callback(group, .error(InvalidResultError()))
//        }
//      } else {
//        callback(group, .error(InvalidResultError()))
//      }
//    }
//    task.resume()
//    return task
//  }
//
  public func searchForEvents(withKeyword text: String, andRadius radius: Int, _ callback: @escaping ((Result<[MeetupGroupEvents]>) -> Void)) {
    let maxCount = 20
    
    let request = FindGroupsByTextRequest(text: "cocoaheads", radius: 100, groupEventMaxCount: 20)
    self.task(withRequest: request) { (request, result) in
      guard case .result(let groups) = result else {
        return assertionFailure()
        
      }
      var allGroupEvents = [MeetupGroupEvents]()
      var resultError : Error?
      print("Data Downloaded, Parsing...")
      //print(String(data: data!, encoding: String.Encoding.utf8))
      print("Completed")
      let dispatchGroup = DispatchGroup()
      for group in groups {
        print("Pulling Events for \(group.name)...")
        dispatchGroup.enter()
        DispatchQueue.main.async(group: dispatchGroup, qos: .default, flags: DispatchWorkItemFlags(), execute: {
          let request = FetchGroupEventsRequest(group: group)
          self.task(withRequest: request, { (request, result) in

            switch result {

            case .result(let groupEvents):
              allGroupEvents.append((group: request.group, events: groupEvents))
              break
            case .error(let error):
              resultError = error
            }
            print("Completed Events for \(group.name)...")
            dispatchGroup.leave()
          })
        })

      }

      dispatchGroup.notify(queue: .main, execute: {
        if let error = resultError {
          callback(.error(error))
        } else {
          callback(.result(allGroupEvents))
        }
      })
    }

  }
}

let meetupAPI = MeetupAPI(apiKey: apiKey)

meetupAPI.searchForEvents(withKeyword: "cocoaheads", andRadius: 100) { (result) in
  
  print(result)
  PlaygroundPage.current.finishExecution()
}
print("Pulling Group Information...")
