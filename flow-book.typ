// Copyright 2026 Leedehai.
// Use of this code is governed by a MIT license in the LICENSE.txt file.
// Repository: https://github.com/Leedehai/typst-flow-book
//
// Usage:
// ```
// #import "flow-book.typ" as book
//
// #show: book.setup.with(title: "My Awesome Book", ...)
//
// Your content here.
// ```

#import "@preview/marginalia:0.3.1" as marginalia
#import "@preview/in-dexter:0.7.2" as in-dexter

#import "lib.typ": setup-impl

/// Put a side note. Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// foo#book.note[This is a side note]
/// ```
#let note = marginalia.note.with(
  numbering: (.., n) => super(text(fill: eastern)[#numbering("a", n)]),
)

/// Put a side note figure. Use `dy` to adjust y-position if needed.
///
/// Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// foo#book.notefigure[This is a side note]
/// ```
#let notefigure = marginalia.notefigure

/// Put a block of content that occupies both the main text and the
/// margin that's otherwise reserved for side ntoes. Useful for
/// wide figures and tables, etc. Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// #book.wideblock[...]
/// ```
#let wideblock = marginalia.wideblock

/// Add a index. Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// This is called a dog#book.index[dog].
/// This is a _laptop computer_#book.index("computer!laptop"), and
/// this is a desktop computer#book.index("computer!desktop").
/// ```
#let index = in-dexter.index

/// The setup. Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// #show book.setup.with(title: "My Awesome Book", ...)
///
/// Your content here.
/// ```
#let setup(
  title: "",
  subtitle: "",
  title-head: "",
  author: "",
  publisher: "",
  versioning: (build-date: auto, version: "version 1.0"),
  paper-size: "a4",
  copyright-page: none,
  opening-page: none,
  dedication-page: none,
  foreword: none,
  preface: none,
  show-table-of-contents: false,
  show-list-of-figures: false,
  show-list-of-tables: false,
  show-chapter-outline: true,
  appendices: [],
  show-index: false,
  margin-note-metrics: (width: 5.2cm, sep: 1em),
  body,
) = {
  let opts = (
    title: title,
    subtitle: subtitle,
    title-head: title-head,
    author: author,
    publisher: publisher,
    versioning: versioning,
    paper-size: paper-size,
    copyright-page: copyright-page,
    opening-page: opening-page,
    dedication-page: dedication-page,
    foreword: foreword,
    preface: preface,
    show-table-of-contents: show-table-of-contents,
    show-list-of-figures: show-list-of-figures,
    show-list-of-tables: show-list-of-tables,
    show-chapter-outline: show-chapter-outline,
    appendices: appendices,
    show-index: show-index,
    margin-note-metrics: margin-note-metrics,
  )
  setup-impl(opts, body)
}
