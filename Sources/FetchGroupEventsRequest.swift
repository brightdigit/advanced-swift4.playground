import Foundation

public struct FetchGroupEventsRequest : Request {
  public typealias ResultType = [MeetupEvent]
  
  public let group : MeetupGroup
  
  public init (group: MeetupGroup) {
    self.group = group
  }
  
  public func urlWith(apiKey: String) -> URL {
    let urlString = "https://api.meetup.com/\(self.group.urlname)/events?&sign=true&photo-host=public&page=100&status=upcoming,past&only=id,name,description,link,time,yes_rsvp_count,duration"
    return URL(string: urlString)!
  }
}
