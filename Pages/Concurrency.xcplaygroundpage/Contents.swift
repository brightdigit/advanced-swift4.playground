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


public struct MeetupAPI {
  public let apiKey : String
  
  public static let decoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    return decoder
  }()
  public func fetchEvents (forGroup group: MeetupGroup, callback: @escaping ((MeetupGroup, Result<[MeetupEvent]>) -> Void)) -> URLSessionDataTask {
    let urlString = "https://api.meetup.com/\(group.urlname)/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration"
    let url = URL(string: urlString)!
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      if let error = error {
        callback(group, .error(error))
      } else if let data = data {
        var events : [MeetupEvent]?
        var actualError : Error?
        do {
          events = try MeetupAPI.decoder.decode([MeetupEvent].self, from: data)
        }
        catch let error {
          actualError = error
        }
        if let events = events {
          callback(group, .result(events))
        } else if let error = actualError {
          callback(group, .error(error))
        } else {
          callback(group, .error(InvalidResultError()))
        }
      } else {
        callback(group, .error(InvalidResultError()))
      }
    }
    task.resume()
    return task
  }
  
  public func searchForEvents(withKeyword text: String, andRadius radius: Int, _ callback: @escaping ((Result<[MeetupGroupEvents]>) -> Void)) {
    let maxCount = 20
    let urlString = "https://api.meetup.com/find/groups?&sign=true&photo-host=public&upcoming_events=true&text=\(text)&radius=\(radius)&page=\(maxCount)&sign=true&key=\(self.apiKey)"
    
    let url = URL(string: urlString)!
    
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      var allGroupEvents = [MeetupGroupEvents]()
      var resultError : Error?
      print("Data Downloaded, Parsing...")
      //print(String(data: data!, encoding: String.Encoding.utf8))
      let groups = try! MeetupAPI.decoder.decode([MeetupGroup].self, from: data!)
      print("Completed")
      let dispatchGroup = DispatchGroup()
      for group in groups {
        print("Pulling Events for \(group.name)...")
        dispatchGroup.enter()
        guard error == nil else {
          return dispatchGroup.leave()
        }
        DispatchQueue.main.async(group: dispatchGroup, qos: .default, flags: DispatchWorkItemFlags(), execute: {
          self.fetchEvents(forGroup: group, callback: { (group, result) in
            
            switch result {
              
            case .result(let groupEvents):
              allGroupEvents.append((group: group, events: groupEvents))
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
    
    task.resume()
  }
}

let meetupAPI = MeetupAPI(apiKey: apiKey)
meetupAPI.searchForEvents(withKeyword: "cocoaheads", andRadius: 100) { (result) in
  
  print(result)
  PlaygroundPage.current.finishExecution()
}
print("Pulling Group Information...")
