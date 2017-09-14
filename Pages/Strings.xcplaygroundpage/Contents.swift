//: [Previous](@previous)
/*:
 ## Strings are a Pain
 
 Some very basic tasks can be fairly difficult. One of those is formatting strings...
 
 ### String Formatting
 */
import Foundation
let location = "🌳🌙"
//: The easiest way is by using the default method in Swift with the \\(*) notation.
func meetupWelcomeMessage(forCityOf cityName: String, locatedAt locationName: String) -> String {
  return "🎉Welcome to \(cityName) Cocoaheads, at \(locationName)!!🍾"
}
var str = meetupWelcomeMessage(forCityOf: "Ann Arbor", locatedAt: location)
//: The other way is by using the String.init(format:, arguments) method
String(format: "🎉Welcome to %@ Cocoaheads, at %@!!🍾", "Ann Arbor",location)
//: This way is familiar for those who are use to Objective-C, C, and other C-based languages.
/*:
 #### Conclusion
 
 Here the reason why you may choose one over the other:
 
 **Native Swift Method**
 * Cleanest Method and Most Supported
 * Allows for Further Customization in a Method as Opposed to a Special Syntax.
 
 **C-Style Method**
 * Best For Those Who Are Already Familiar with C-Style Formatting
 * Good For Custom Formatting of Numeric Types (Int, Double, etc...)

 ### Strings are Collections (Swift 4)
 
 
 Now you can treat Strings as Character Collections. This means you can access the String with Sequence Closure Methods as well as with String.Index and Range<String.Index>.
 
 #### String.Index and Range Subscript
 
 Which means you use String.Index for:
 * Accessing Single Characters with Subscripts
 * Accessing Substrings with Range Subscripts
 
 Here is an example:

 Let's create an index for the last character
 */
let indexBeforePopper = str.index(before: str.endIndex)
//: Then we create an index for the end of the location
let indexAppleStoreEnd = str.index(indexBeforePopper, offsetBy: -3)
//: Next we create an index for the start of the location
let indexAppleStoreStart = str.index(indexAppleStoreEnd, offsetBy: -3-location.count)
//: Now we can get just the popper character
let popper = str[indexBeforePopper]
//: Or we can get the substring of the location
let appleStore = str[indexAppleStoreStart...indexAppleStoreEnd]
/*:
 #### String Closure Methods
 
 We now have access to the set of Collection Methods which loop through each character.
 */
//: Of course we can loop through the characters
for character in str {
  //print(character)
}
//: But we can do things like use *dropLast* to remove the last two character like an array
let strWithLessFanFare = str.dropLast(2)
//: We can use *filter* remove all non-ascii characters
let strWithLessEmoji = str.filter{ $0.unicodeScalars.contains(where: { $0.isASCII })}
//: We can use *reverse*
let reverseIt = String(str.reversed())
//: We can do other things like split the string then mix the characters
let splitStrings = str.components(separatedBy: ",")
zip(splitStrings.first!, splitStrings.last!).reduce("") { (current : String, characters : (Character, Character)) -> String in
  return current.appending(String(current.count % 2 == 1 ? characters.1 : characters.0))
}

//: [Next](@next)
