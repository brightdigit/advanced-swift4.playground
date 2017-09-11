import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

public struct InvalidResultError : Error {
  
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970

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


var events = [MeetupEvent]()

public struct MeetupGroup : Codable {
  public let id: Int
  public let name: String
  public let link: URL
  public let description: String
  public let created: Date
  public let organizer: MeetupMember
  public let urlname: String
  public func fetchEvents (callback: @escaping ((Result<[MeetupEvent]>) -> Void)) -> URLSessionDataTask {
    let urlString = "https://api.meetup.com/\(self.urlname)/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration"
    let url = URL(string: urlString)!
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      if let error = error {
        callback(.error(error))
      } else if let data = data {
        var events : [MeetupEvent]?
        var actualError : Error?
        do {
          events = try decoder.decode([MeetupEvent].self, from: data)
        }
        catch let error {
          actualError = error
        }
        if let events = events {
          callback(.result(events))
        } else if let error = actualError {
          callback(.error(error))
        } else {
          callback(.error(InvalidResultError()))
        }
      } else {
        callback(.error(InvalidResultError()))
      }
    }
    task.resume()
    return task
  }
}

guard let meetup_api_key_url = Bundle.main.url(forResource: "meetup_api_key", withExtension: nil) else {
  assertionFailure("No meetup api key file")
  PlaygroundPage.current.finishExecution()
}

guard let apiKey = try? String(contentsOf: meetup_api_key_url).trimmingCharacters(in: .whitespacesAndNewlines) else {
  assertionFailure("No MEETUP_API_KEY set")
  PlaygroundPage.current.finishExecution()
}

let urlString = "https://api.meetup.com/find/groups?&sign=true&photo-host=public&upcoming_events=true&text=Cocoaheads&radius=100&page=20&sign=true&key=\(apiKey)"

let url = URL(string: urlString)!

let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
  
  print("Data Downloaded, Parsing...")
  //print(String(data: data!, encoding: String.Encoding.utf8))
  let groups = try! decoder.decode([MeetupGroup].self, from: data!)
  print("Completed")
  let dispatchGroup = DispatchGroup()
  for group in groups {
    print("Pulling Events for \(group.name)...")
    dispatchGroup.enter()
      DispatchQueue.main.async(group: dispatchGroup, qos: .default, flags: DispatchWorkItemFlags(), execute: {
        
        _ = group.fetchEvents(callback: { (result) in
          switch result {
          
          case .result(let groupEvents):
            events.append(contentsOf: groupEvents)
            break
          default:
            assertionFailure("Error pulling events for \(group.name).")
          }
          print("Completed Events for \(group.name)...")
          dispatchGroup.leave()
        })
      })
    
  }
  
  dispatchGroup.notify(queue: .main, execute: {
    print(events)
    PlaygroundPage.current.finishExecution()
    
  })
}

task.resume()

print("Pulling Group Information...")
//let data = try! Data(contentsOf: url)
//import Foundation
//import PlaygroundSupport
//
////: [Previous](@previous)
//import Foundation
//import PlaygroundSupport
//
//extension Sequence {
//  func filterBy<Root, Value>(path: KeyPath<Root, Value>, by closure: (Value) -> Bool) -> [Self.Element] where Self.Element == (Root) {
//    return self.filter({ (item) -> Bool in
//      let value = item[keyPath: path]
//      return closure(value)
//    })
//  }
//}
//
//public struct Photo : Codable {
//  public let id: Int
//
//}
//
////
//public struct MeetupEvent : Codable {
//  public let time:Date
//  public let name:String
//  public let description:String
//  public let link:URL
//  public let id:String
//  public let duration:TimeInterval?
//  public let rsvps:Int
//
//
//  enum CodingKeys : String, CodingKey {
//    case time
//    case name
//    case description
//    case link
//    case id
//    case duration
//    case rsvps = "yes_rsvp_count"
//  }
//}
////
//let decoder = JSONDecoder()
//decoder.dateDecodingStrategy = .millisecondsSince1970
////
//
//let url = URL(string: "https://api.meetup.com/A2-Cocoaheads/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration")!
////let text = try! String(contentsOf: url)
//let data = try! Data(contentsOf: url)
////let task = session.dataTask(with: url) { (data, _, error) in
//let nameKeyPath = \Meetup.name
//let allMeetups = try! decoder.decode([MeetupEvent].self, from: data)
//let filteredMeetups = allMeetups.filterBy(path: nameKeyPath, by: {$0 != "COCOA CODELAB"})
//print(filteredMeetups)
//
////let meetups = try! decoder.decode([Meetup].self, from: data).filter({$0[keyPath: nameKeyPath] != "COCOA CODELAB"})
//
////let meetups = try! decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
////  print("test")
////  print(meetups.first?[keyPath: nameKeyPath])
////  PlaygroundPage.current.finishExecution()
////}
//
////task.resume()
//
////PlaygroundPage.current.needsIndefiniteExecution = true
//
////: [Next](@next)
//
//func run(after seconds: Int, closure: @escaping () -> Void) {
//  let time = DispatchTime.now() + DispatchTimeInterval.seconds(seconds)
//  let queue = DispatchQueue(label: "com.example.runqueue")
//  queue.asyncAfter(deadline: time, qos: .background, flags: .inheritQoS) {
//    closure()
//  }
//}
//
//let group = DispatchGroup()
//
//group.enter()
//run(after: 6) {
//  print("Hello after 6 seconds")
//  group.leave()
//}
//
//group.enter()
//run(after: 4) {
//  print("Hello after 4 seconds")
//  group.leave()
//}
//
//group.enter()
//run(after: 2) {
//  print("Hello after 2 seconds")
//  group.leave()
//}
//
//group.enter()
//run(after: 1) {
//  print("Hello after 1 second")
//  group.leave()
//}
//
//
//group.notify(queue: DispatchQueue.global(qos: .background)) {
//  print("All async calls were run!")
//  PlaygroundPage.current.finishExecution()
//}
//

