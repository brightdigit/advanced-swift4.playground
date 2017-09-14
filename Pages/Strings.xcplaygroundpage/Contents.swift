//: [Previous](@previous)
import Foundation
//An Example of how to treat a String as an array of characters

func meetupWelcomeMessage(forCityOf cityName: String, locatedAt locationName: String) -> String {
  return "🎉Welcome to \(cityName) Cocoaheads, at \(locationName)!!🍾"
}

var str = meetupWelcomeMessage(forCityOf: "Ann Arbor", locatedAt: "🌳🌙")

String(format: "🎉Welcome to %@ Cocoaheads, at %@!!🍾", "Ann Arbor", "🌳🌙")

//NSRegularExpression(pattern: "🎉Welcome to  Cocoaheads, at the \(locationName)!!🍾", options: NSRegularExpression.Options())
// loop through the characters
for character in str {
  //print(character)
}

// create an index for the last character
let indexBeforePopper = str.index(before: str.endIndex)

// create an index for the end of the Apple Store
let indexAppleStoreEnd = str.index(indexBeforePopper, offsetBy: -3)

// create an index for the start of the Apple Store
let indexAppleStoreStart = str.index(indexAppleStoreEnd, offsetBy: -6)

// get the popper character
let popper = str[indexBeforePopper]

// get the substring of the Apple Store
let appleStore = str[indexAppleStoreStart...indexAppleStoreEnd]

// remove the last two character like an array
let strWithLessFanFare = str.dropLast(2)

// remove all non-ascii characters
let strWithLessEmoji = str.filter{ $0.unicodeScalars.contains(where: { $0.isASCII })}

// reverse the string
let reverseIt = String(str.reversed())

// split the string then mix the characters
let splitStrings = str.components(separatedBy: ",")
zip(splitStrings.first!, splitStrings.last!).reduce("") { (current : String, characters : (Character, Character)) -> String in
  return current.appending(String(current.count % 2 == 1 ? characters.1 : characters.0))
}

//: [Next](@next)
