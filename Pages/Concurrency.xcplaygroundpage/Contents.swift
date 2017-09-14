/*:
 [Previous](@previous)
 ## Grand Central Dispatch
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension MeetupAPI {
  public func searchForEvents(withKeyword text: String, andRadius radius: Int, _ callback: @escaping ((Result<[MeetupGroupEventSet]>) -> Void)) {
    let maxCount = 20
    
    let request = FindGroupsByTextRequest(text: text, radius: radius, groupEventMaxCount: 20)
    self.task(withRequest: request) { (request, result) in
      guard case .result(let groups) = result else {
        return assertionFailure()
        
      }
      var allGroupEvents = [MeetupGroupEventSet]()
      var resultError : Error?
      print("Data Downloaded, Parsing...")
      print("Completed")
      let dispatchGroup = DispatchGroup()
      for group in groups {
        print("Pulling Events for \(group.name)...")
        dispatchGroup.enter()
        DispatchQueue.main.async(group: dispatchGroup, qos: .default, flags: DispatchWorkItemFlags(), execute: {
          let request = FetchGroupEventsRequest(group: group)
          self.task(withRequest: request, { (request, result) in
            
            switch result {
              
            case .result(let groupEvents):
              allGroupEvents.append((group: request.group, events: groupEvents))
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
  }
}


let apiKey = try! MeetupAPI.getApiKey()
let meetupAPI = MeetupAPI(apiKey: apiKey)

meetupAPI.searchForEvents(withKeyword: "cocoaheads", andRadius: 100) { (result) in
  
  print(result)
  PlaygroundPage.current.finishExecution()
}
print("Pulling Group Information...")
