import Foundation

try "some text".writeToFile(NSHomeDirectory() + "/.endroid", atomically: false, encoding: NSUTF8StringEncoding)