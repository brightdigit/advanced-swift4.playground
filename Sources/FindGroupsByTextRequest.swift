import Foundation

public struct FindGroupsByTextRequest : Request {
  public typealias ResultType = [MeetupGroup]
  
  public let text : String
  public let radius : Int
  public let groupEventMaxCount : Int
  
  public init (text: String, radius: Int, groupEventMaxCount: Int) {
    self.text = text
    self.radius = radius
    self.groupEventMaxCount = groupEventMaxCount
  }
  
  public func urlWith(apiKey: String) -> URL {
    let urlString = "https://api.meetup.com/find/groups?&sign=true&photo-host=public&upcoming_events=true&text=\(self.text)&radius=\(self.radius)&page=\(self.groupEventMaxCount)&sign=true&key=\(apiKey)"
    return URL(string: urlString)!
  }
}
