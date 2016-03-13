#!/usr/bin/env swift

import Foundation
import CoreServices

func definition(word: String) -> CFString? {
    return DCSCopyTextDefinition(nil, word, CFRangeMake(0, word.characters.count))?
    .takeUnretainedValue()
}

func trimmed(str: String) -> String {
    return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}

func main() {
    if let word = Process.arguments.dropFirst().first as String? {
        if let definition = definition(trimmed(word)) {
            print(definition)
        }
    }
}

main()