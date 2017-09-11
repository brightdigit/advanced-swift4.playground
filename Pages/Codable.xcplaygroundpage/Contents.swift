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
  public let id:Int
  
  public init(from decoder: Decoder)  throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.description = try container.decode(String.self, forKey: .description)
    self.time = try container.decode(Date.self, forKey: .time)
    self.link = try container.decode(URL.self, forKey: .link)
    
    let idString = try container.decode(String.self, forKey: .id)
    
    guard let id = Int(idString) else {
      throw MeetupDecoderError()
    }
    
    self.id = id
  }
}

let url = URL(string: "https://api.meetup.com/Lansing-CocoaHeads/events")!

let session = URLSession(configuration: .default)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970

let task = session.dataTask(with: url) { (data, _, error) in
  let meetups = try! decoder.decode([Meetup].self, from: data!)
  print(meetups)
  PlaygroundPage.current.finishExecution()
}

task.resume()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
