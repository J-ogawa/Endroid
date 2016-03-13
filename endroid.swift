#!/usr/bin/env swift -F Carthage/Build/Mac

import SQLite

extension String {
  private func checkingResults(pattern:String) -> [NSTextCheckingResult] {
    return try! NSRegularExpression(pattern:pattern,options:NSRegularExpressionOptions())
    .matchesInString(self,
      options: NSMatchingOptions(),
      range: NSMakeRange(0, self.characters.count))
  }

  private func convertToStrings(result: NSTextCheckingResult) -> [String] {
    return Array(0..<result.numberOfRanges).map { index in
      (self as NSString).substringWithRange(result.rangeAtIndex(index))
    }
  }

  func match(pattern: String) -> [String]? {
    if let result = checkingResults(pattern).first {
      return convertToStrings(result)
    } else {
      return nil
    }
  }

  func matches(pattern: String) -> [[String]] {
    return checkingResults(pattern).map { result in convertToStrings(result) }
  }
}

func createWords(conn: Connection) {
  try! conn.run(Table("words").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<String>("name"), unique: true)
  })
}

func createMeanings(conn: Connection) {
  try! conn.run(Table("meanings").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<Int64>("word_id"))
    t.column(Expression<Int64>("lexical_category_id"))
    t.column(Expression<String>("description"))
  })
}
func createSentences(conn: Connection) {
  try! conn.run(Table("sentences").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<Int64>("sentence_tamplate_id"))
    t.column(Expression<String>("body"), unique: true)
  })
}

func createLexicalCategories(conn: Connection) {
  try! conn.run(Table("lexical_categories").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<String>("name"), unique: true)
  })
}

func createSentenceTemplates(conn: Connection) {
  try! conn.run(Table("sentence_tamplates").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<String>("identifier"), unique: true)
  })
}

func migrate() {
  let db = try! Connection("db.sqlite3")

  // try! db.run(Table("words").drop(ifExists: true))
  // try! db.run(Table("meanings").drop(ifExists: true))
  // try! db.run(Table("sentences").drop(ifExists: true))
  // try! db.run(Table("lexical_categories").drop(ifExists: true))
  // try! db.run(Table("sentence_tamplates").drop(ifExists: true))

  createWords(db)
  createMeanings(db)
  createSentences(db)
  createLexicalCategories(db)
  createSentenceTemplates(db)
}

func lexicalCategories(definition: String) -> [String] {
  return definition.matches("(▶.*?)\\s").map{ $0.last! }
}

func definition(word: String) -> String? {
  if let definition = DCSCopyTextDefinition(nil, word, CFRangeMake(0, word.characters.count))?
  .takeUnretainedValue() {
    return String(definition)
  } else {
    return nil
  }
}

func trimmed(str: String) -> String {
  return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}

func memorize(word: String, lexical_category: String, description: String) -> [String:Int64] {
  let word_id = memorizeUniqueName(word, table: "words")
  let lexical_category_id = memorizeUniqueName(lexical_category, table: "lexical_categories")
  let conn = try! Connection("db.sqlite3")
  let meaning_id = try! conn.run(Table("meanings").insert(
  Expression<Int64>("word_id") <- word_id,
  Expression<Int64>("lexical_category_id") <- lexical_category_id,
  Expression<String>("description") <- description)
  )
  return ["word_id": word_id, "lexical_category_id": lexical_category_id, "meaning_id": meaning_id]
}

func memorizeUniqueName(name: String, table: String) -> Int64 {
  let conn = try! Connection("db.sqlite3")
  var id: Int64
  let name_col = Expression<String>("name")
  do {
    id = try conn.run(Table(table).insert(name_col <- name))
  } catch {
    id = try! Array(conn.prepare(Table(table).filter(name_col == name))).first![Expression<Int64>("id")]
  }
  return id
}

func main() {
  migrate()

  if let word = Process.arguments.dropFirst().first {
    if let definition = definition(word) {
      print(definition)
      let createStatus = definition.characters.split("▶").dropFirst().map(String.init)
      .map{ (categoryDescription: String) -> [String:Int64] in
        let result = categoryDescription.match("(.*?)\\s(.*)")!
        return memorize(word, lexical_category: result[1], description: result[2])
      }
      print(createStatus)
    }
  }
}

main()