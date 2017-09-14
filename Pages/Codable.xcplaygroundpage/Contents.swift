//: [Previous](@previous)
import Foundation
import PlaygroundSupport


let url = URL(string: "https://api.meetup.com/A2-Cocoaheads/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration")!

let session = URLSession(configuration: .default)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970
//
//let task = session.dataTask(with: url) { (data, _, error) in
//  let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String : Any]]
//
//  let meetupEvents = json.map({ (obj) -> MeetupEvent in
//    let time = Date(timeIntervalSince1970: obj["time"] as! TimeInterval)
//    let name = obj["name"] as! String
//    let description = obj["description"] as! String
//    let link = URL(string: obj["link"] as! String)!
//    let id = obj["id"] as! String
//    return MeetupEvent(time: time, name: name, description: description, link: link, id: id)
//  })
//  print(meetupEvents)
//  PlaygroundPage.current.finishExecution()
//}


let task = session.dataTask(with: url) { (data, _, error) in
  let meetupEvents = try! decoder.decode([MeetupEvent].self, from: data!)
  PlaygroundPage.current.finishExecution()
}

task.resume()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
