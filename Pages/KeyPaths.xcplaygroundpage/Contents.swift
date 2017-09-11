//: [Previous](@previous)
import Foundation
import PlaygroundSupport

public struct MeetupDecoderError : Error {
  
}

public struct Meetup : Codable {
  public let time:Date
  public let name:String
  public let description:String
  public let link:URL
  public let id:String
  
}

let url = URL(string: "https://api.meetup.com/A2-Cocoaheads/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration")!

let session = URLSession(configuration: .default)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970

let task = session.dataTask(with: url) { (data, _, error) in
  let nameKeyPath = \Meetup.name
  let meetups = try! decoder.decode([Meetup].self, from: data!).filter({$0[keyPath: nameKeyPath] != "COCOA CODELAB"})
  print(meetups)
  PlaygroundPage.current.finishExecution()
}

task.resume()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
