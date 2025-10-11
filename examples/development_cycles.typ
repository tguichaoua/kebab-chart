#import "../src/lib.typ": kebab-chart

#set page(width: auto, height: auto, margin: 0.5cm)

#let DEV = blue
#let ALPHA = red
#let BETA = orange
#let RC = yellow
#let STABLE = green

#let WIDTH = 30cm
#let TODAY = datetime(year: 2025, month: 10, day: 29)

#let data = (
  (
    label: "1.0.0",
    spans: (
      (start: datetime(year: 2025, month: 9, day: 22), end: datetime(year: 2025, month: 10, day: 2), fill: DEV),
      (start: datetime(year: 2025, month: 10, day: 2), end: datetime(year: 2025, month: 10, day: 7), fill: ALPHA),
      (start: datetime(year: 2025, month: 10, day: 7), end: datetime(year: 2025, month: 10, day: 14), fill: BETA),
      (start: datetime(year: 2025, month: 10, day: 14), end: datetime(year: 2025, month: 10, day: 21), fill: RC),
      (start: datetime(year: 2025, month: 10, day: 21), end: datetime(year: 2025, month: 11, day: 4), fill: STABLE),
    ),
  ),
  (
    label: "1.1.0",
    spans: (
      (start: datetime(year: 2025, month: 10, day: 6), end: datetime(year: 2025, month: 10, day: 16), fill: DEV),
      (start: datetime(year: 2025, month: 10, day: 16), end: datetime(year: 2025, month: 10, day: 21), fill: ALPHA),
      (start: datetime(year: 2025, month: 10, day: 21), end: datetime(year: 2025, month: 10, day: 28), fill: BETA),
      (start: datetime(year: 2025, month: 10, day: 28), end: datetime(year: 2025, month: 11, day: 4), fill: RC),
      (start: datetime(year: 2025, month: 11, day: 4), end: datetime(year: 2025, month: 11, day: 18), fill: STABLE),
    ),
  ),
  (
    label: "1.2.0",
    spans: (
      (start: datetime(year: 2025, month: 10, day: 20), end: datetime(year: 2025, month: 10, day: 30), fill: DEV),
      (start: datetime(year: 2025, month: 10, day: 30), end: datetime(year: 2025, month: 11, day: 4), fill: ALPHA),
      (start: datetime(year: 2025, month: 11, day: 4), end: datetime(year: 2025, month: 11, day: 11), fill: BETA),
      (start: datetime(year: 2025, month: 11, day: 11), end: datetime(year: 2025, month: 11, day: 18), fill: RC),
      (start: datetime(year: 2025, month: 11, day: 18), end: datetime(year: 2025, month: 12, day: 2), fill: STABLE),
    ),
  ),
)

#{
  let LEGENDS = (
    (name: "Dev", color: DEV),
    (name: "Alpha", color: ALPHA),
    (name: "Beta", color: BETA),
    (name: "RC", color: RC),
    (name: "Stable", color: STABLE),
  )

  let label(name, color) = align(horizon, stack(
    dir: ltr,
    spacing: 5pt,
    rect(height: 0.5cm, width: 0.5cm, fill: color, stroke: black),
    name,
  ))

  align(horizon, stack(dir: ltr, spacing: 10pt, ..LEGENDS.map(((name, color)) => label(name, color))))
}

#kebab-chart(
  data,

  width: WIDTH,

  ticks: dates => {
    let start = dates.visible_start
    let end = dates.visible_end

    let ticks = ()

    // Add a tick at the begin of each 2 weeks cycles
    let i = dates.data_start
    while i < end {
      ticks.push(i)
      i += duration(days: 14)
    }

    // Add a tick for the "today" date
    ticks.push((
      date: TODAY,
      content: [#v(0.4cm) #text(fill: red, "Today")],
      color: red,
    ))

    ticks
  },

  bookmarks: dates => {
    let start = dates.visible_start
    let end = dates.visible_end

    let marks = ()

    // Select the next saturday from start
    let i = if start.weekday() == 6 {
      start
    } else if start.weekday() < 6 {
      start + duration(days: 6 - start.weekday())
    } else {
      start + duration(days: 13 - start.weekday())
    }

    // Add a gray zone for each week-ends
    while i < end {
      marks.push((
        date: (i, i + duration(days: 2)),
        position: "below",
        stroke: none,
        fill: gray,
      ))

      i += duration(days: 7)
    }


    // Select the next monday from start
    start = dates.data_start
    let i = if start.weekday() == 1 {
      start
    } else {
      start + duration(days: 8 - start.weekday())
    }

    let j = 0
    while i < end {
      if i + duration(days: 14) <= end {
        // A mark at the middle of each cycle to name it
        marks.push((
          date: i + duration(days: 7),
          stroke: (thickness: 0pt),
          position: "below",
          content: [#text(size: 1.2em)[Cycle #{ j + 1 }] #v(0.3cm)],
        ))

        // Colorize the span of the cycle
        marks.push((
          date: (i, i + duration(days: 14)),
          position: "below",
          stroke: none,
          fill: if calc.rem(j, 2) == 0 { blue } else { orange }.transparentize(85%),
        ))
      }

      i += duration(days: 14)
      j += 1
    }

    marks.push((
      date: TODAY,
      stroke: (thickness: 1pt, paint: red),
    ))

    marks
  },
)
