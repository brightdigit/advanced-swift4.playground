import Foundation

public struct MeetupEvent : Codable {
  public let time:Date
  public let name:String
  public let description:String
  public let link:URL
  public let id:String
}

