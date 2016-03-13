#!/usr/bin/env swift -F Carthage/Build/Mac

import SQLite

func createWords(conn: Connection) {
  try! conn.run(Table("words").create(ifNotExists: true) { t in
    t.column(Expression<Int64>("id"), primaryKey: .Autoincrement)
    t.column(Expression<Int64>("lexical_categoty_id"))
    t.column(Expression<String>("name"), unique: true)
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
  try! conn.run(Table("lexical_categoties").create(ifNotExists: true) { t in
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

func main() {
  let db = try! Connection("db.sqlite3")
  createWords(db)
  createSentences(db)
  createLexicalCategories(db)
  createSentenceTemplates(db)
}

main()