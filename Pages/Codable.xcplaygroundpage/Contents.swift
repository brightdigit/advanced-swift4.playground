//: [Previous](@previous)
/*:
 ## Encoding and Decoding Data
 
 
 ### The Old Way (Swift 3)
 
 In Swift 3 when we wanted to encode or decode data such as JSON, we had to:
 
 1. Use JSONSerialization To Create an Any
 2. Cast Any to Dictionary or Collection of Dictionaries
 3. Convert Dictionary or Collection into Struct or Class
 
 ````
 let task = session.dataTask(with: url) { (data, _, error) in
 let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String : Any]]
 
 let meetupEvents = json.map({ (obj) -> MeetupEvent in
 let time = Date(timeIntervalSince1970: obj["time"] as! TimeInterval)
 let name = obj["name"] as! String
 let description = obj["description"] as! String
 let link = URL(string: obj["link"] as! String)!
 let id = obj["id"] as! String
 return MeetupEvent(time: time, name: name, description: description, link: link, id: id)
 })
 }
 ````
 
 However in Swift 4, we have a new set of APIs to make this much **much** easier. A major part of that is the `Codable` protocol.
 
 ### The Codable Protocol (Swift 4)
 
 Codable makes this much easier but also has room for flexibility. This means:
 * No Need For Cast or Conversion
 * Apply Protocol
 * Allows Various Layers of Customability
 
 To make a Class or Structure compatible we just need to apply the `Codable` protocol.
 ````
 public struct MeetupEvent : Codable {
 public let time:Date
 public let name:String
 public let description:String
 public let link:URL
 public let id:String
 }
 ````
 Let's setup our `URL` and `URLSession`.
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
let url = URL(string: "https://api.meetup.com/A2-Cocoaheads/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration")!
let session = URLSession(configuration: .default)
//: Next we create a `JSONDecoder`
let decoder = JSONDecoder()
//: The Meetup API returns a Date as a Unix Timestamp, so we need to note the `.dateDecodingStrategy. for the decoder.
decoder.dateDecodingStrategy = .millisecondsSince1970
//: Alright, let's create our dataTask
let task = session.dataTask(with: url) { (data, _, error) in
  let meetups = try! decoder.decode([MeetupEvent].self, from: data!)
  for meetup in meetups {
    print(meetup.time, meetup.name)
  }
  PlaygroundPage.current.finishExecution()
}
//: Now let's run our task and we should get our `MeetupEvent` automatically decoded.
task.resume()
//: [Next](@next)
