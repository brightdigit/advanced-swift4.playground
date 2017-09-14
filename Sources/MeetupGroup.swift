import Foundation

public struct MeetupGroup : Codable {
  public let id: Int
  public let name: String
  public let link: URL
  public let description: String
  public let created: Date
  public let organizer: MeetupMember
  public let urlname: String
  
}
