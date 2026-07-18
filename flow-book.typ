// Copyright 2026 Leedehai.
// Use of this code is governed by a MIT license in the LICENSE.txt file.
// Repository: https://github.com/Leedehai/typst-flow-book
//
// Usage:
// ```
// #show flow-book.with(title: "My Awesome Book", ...)
//
// Your content here.
// ```

#import "@preview/marginalia:0.3.1" as marginalia
#import "@preview/in-dexter:0.7.2": index, make-index
#import "@preview/suboutline:0.3.0": suboutline
#import "@preview/hydra:0.6.3": hydra

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

/// Put an indexed term. Usage:
/// ```
/// #import "@preview/flow-book:x.y.z" as book
/// This is called #book.indexed[Computation Offloading].
/// ```
#let indexed(term) = {
  term + index(term)
}

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
  versioning: (build-date-pattern: auto, version: "version 1.0"),
  paper-size: "a4",
  cover-page: none,
  copyright-page: none,
  opening-page: none,
  dedication-page: none,
  foreword: none,
  preface: none,
  show-table-of-contents: false,
  show-list-of-figures: false,
  show-list-of-tables: false,
  show-chapter-outline: true,
  appendicies: [],
  show-index: false,
  margin-note-width: 5.2cm,
  page-number-align: auto,
  body,
) = {
  // --- HELPER FUNCTION ---
  // Forces the next content to start on an odd-numbered (right-hand) page
  let odd-pagebreak() = {
    pagebreak(to: "odd", weak: true)
  }

  // --------------------------------- GLOBAL ----------------------------------
  set page(paper: paper-size)
  set super(size: 0.8em)

  // ------------------------------- FRONTMATTER -------------------------------
  {
    odd-pagebreak()
    /*Cover page*/
    [
      #if title-head != none {
        title-head
      }
      #if versioning != none {
        h(1fr)
        let version = if versioning.at("version", default: none) != none {
          versioning.version
        }
        let date = if versioning.at("build-date-pattern", default: none) != none {
          datetime.today().display(versioning.build-date-pattern)
        }
        (version, date).join(h(1em))
      }
      #align(center)[
        #v(1fr)
        #text(size: 28pt, weight: "bold")[#title] \
        #v(1em)
        #text(size: 21pt)[#subtitle] \
        #v(2fr)
        #text(size: 21pt)[#author]
        #v(1em)
        #text(size: 16pt)[#publisher]
        #v(1fr)
      ]
    ]

    if copyright-page != none {
      pagebreak(weak: true)
      copyright-page
    }

    if opening-page != none {
      odd-pagebreak()
      opening-page
    }

    if dedication-page != none {
      odd-pagebreak()
      dedication-page
    }

    if foreword != none {
      odd-pagebreak()
      counter(heading).update(0)
      heading(level: 1, numbering: none)[Foreword]
      foreword
    }

    if preface != none {
      odd-pagebreak()
      counter(heading).update(0)
      heading(level: 1, numbering: none)[Preface]
      preface
    }

    if show-table-of-contents {
      odd-pagebreak()
      outline(title: [Table of Contents], indent: auto)
    }

    if show-list-of-figures {
      odd-pagebreak()
      outline(title: [List of Figures], target: figure.where(kind: image))
    }

    if show-list-of-tables {
      odd-pagebreak()
      outline(title: [List of Tables], target: figure.where(kind: table))
    }
  } // Scoped FRONTMATTER

  // -------------------------------- MAIN BODY --------------------------------
  {
    odd-pagebreak()
    counter(heading).update(0)
    counter(page).update(1)

    set par(justify: true)
    set heading(numbering: "1")

    // Configure marginalia layout (side notes)
    let note-width = margin-note-width
    let note-sep = 1em
    let breakout-width = note-width + note-sep
    show: marginalia.setup.with(
      outer: (width: note-width, sep: note-sep, far: 2cm),
      book: true, // Alternates margins per page
    )

    // Configure the page for main body
    set page(
      numbering: "1",
      number-align: center + top,
      header: context {
        let current-page = here().page()

        let heading-to-show = none
        // 1. Look for a level-1 heading starting on this EXACT page
        let headings-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)
        if headings-on-page.len() > 0 {
          heading-to-show = headings-on-page.first()
        } else {
          // 2. Look for a level-2 heading starting on this EXACT page
          let headings-on-page = query(heading.where(level: 2)).filter(h => h.location().page() == current-page)
          if headings-on-page.len() > 0 {
            heading-to-show = headings-on-page.first()
          } else {
            // 3. Fall back to the most recent level-2 heading from past pages
            let past-headings = query(heading.where(level: 2).before(here()))
            if past-headings != () {
              heading-to-show = past-headings.last()
            }
          }
        }

        // If there's a heading to show, take its number and construct the layout
        if heading-to-show != none {
          let chapter-num = counter(heading).at(heading-to-show.location())
          let (formatted-num, formatted-divider, formatted-heading) = if heading-to-show.level == 1 {
            (
              [],
              [],
              [],
            )
          } else {
            (
              text(style: "italic")[#numbering("1.1", ..chapter-num)],
              box(line(length: 10em, angle: 90deg, stroke: 0.8pt)),
              text(style: "italic")[#heading-to-show.body],
            )
          }

          let page-num = counter(page).get().first()
          if calc.odd(page-num) {
            marginalia.wideblock(align(right, [
              #formatted-heading
              #h(1em)
              #formatted-divider
              #h(1em)
              #box(width: 1cm)[#align(right.inv())[#formatted-num]]
            ]))
          } else {
            marginalia.wideblock(align(left, [
              #box(width: 1cm)[#align(left.inv())[#formatted-num]]
              #h(1em)
              #formatted-divider
              #h(1em)
              #formatted-heading
            ]))
          }
        }
      },
      footer: context {
        let page-num = counter(page).get().first()
        marginalia.wideblock(if page-number-align != auto {
          align(page-number-align)[#page-num]
        } else {
          [#page-num]
        })
      },
    )

    // Remove the separator from the footnote.entry rule, because it
    // is hard to get the starting point of the separator line right,
    // given there is a margin.
    set footnote.entry(separator: none)

    // Forces the footnote text to span the text block + margin width
    // and forces the entry body to appear like an enumerated list entry
    show footnote.entry: it => context {
      let loc = it.note.location()
      let num = counter(footnote).at(loc).first()
      let enum-like-entry = enum(
        numbering: "1",
        body-indent: 1em,
        enum.item(num)[#it.note.body],
      )
      marginalia.wideblock(enum-like-entry)
    }

    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      counter(footnote).update(0)
      marginalia.notecounter.update(0)

      let page-num = counter(page).get().first()
      if it.numbering == none {
        text(size: 1.5em)[#it.body]
      } else {
        let formatted-heading = text(size: 1.5em)[#it.body]
        let formatted-num = text(size: 3em)[
          #numbering(it.numbering, counter(heading).at(it.location()).first())
        ]
        if calc.odd(page-num) {
          let chapter-header = align(right)[
            #box(width: page.width - margin-note-width * 2)[#formatted-heading]
            #h(1em)
            #box(width: margin-note-width)[#align(right.inv())[#h(1em)#formatted-num]]
          ]
          marginalia.wideblock([
            #place(top + right, dx: -margin-note-width, dy: measure(chapter-header).height, line(
              length: 10em,
              angle: 270deg,
            ))
            #chapter-header
            #v(1em)
          ])
        } else {
          let chapter-header = align(left)[
            #box(width: margin-note-width)[#align(left.inv())[#formatted-num#h(1em)]]
            #h(1em)
            #box(width: page.width - margin-note-width * 2)[#formatted-heading]
          ]
          marginalia.wideblock([
            #place(top + left, dx: margin-note-width, dy: measure(chapter-header).height, line(
              length: 10em,
              angle: 270deg,
            ))
            #chapter-header
            #v(1em)
          ])
        }
      }

      // Inject the mini-TOC right below it
      if show-chapter-outline {
        marginalia.note(
          numbering: none,
          block(
            width: note-width,
            text(style: "italic")[
              #suboutline(depth: 1)
            ],
          ),
        )
      }

      v(1em)
    }

    show heading.where(level: 2): it => {
      v(1em)
      it // Render the title
      v(1em)
    }

    body // This is the main body
  } // Scoped MAIN BODY

  // ------------------------------- BACKMATTER --------------------------------
  {
    counter(heading).update(0)
    set par(justify: true)
    set heading(numbering: "I")

    // Disable margin notes
    show: marginalia.setup.with(
      outer: (width: 0pt, sep: 0pt, far: 2.5cm),
    )

    if appendicies.len() != 0 {
      odd-pagebreak()

      set heading(numbering: (..nums) => {
        if nums.pos().len() == 1 {
          "Appendix " + numbering("I.", ..nums.pos())
        } else {
          numbering("I.1", ..nums.pos())
        }
      })

      show heading.where(level: 1): it => {
        text(size: 1.5em)[#it]
        v(1em)
      }

      for appendix in appendicies {
        appendix
      }
    }

    if show-index {
      odd-pagebreak()
      heading(level: 1, numbering: none)[#text(size: 1.5em)[Index]]
      v(1em)
      columns(2)[#make-index(use-page-counter: true)]
    }
  } // Scoped BACKMATTER
}
