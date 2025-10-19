#import "@preview/cetz:0.4.2"

#let kebab-chart(
  ticks: 10,
  date-format: "[day] [month repr:short]",
  start-date: auto,
  end-date: auto,
  date-padding: duration(weeks: 1),
  width: 10cm,
  span-height: 0.3cm,
  vertical-padding: 0.6,
  bookmarks: (),
  label-side: "both",
  weekdays: none,
  data,
) = context {
  cetz.canvas({
    import cetz.draw: *

    let LABEL-PADDING = 0.2cm

    /* -------------------------------------------------------------------------- */
    assert(type(data) == array, message: "'data' is expected to be an array")
    /* -------------------------------------------------------------------------- */
    let VALID-LABEL-SIDE = (none, "both", "right", "left")
    assert(
      VALID-LABEL-SIDE.contains(label-side),
      message: "'label-side' is expected to be one of " + repr(VALID-LABEL-SIDE),
    )
    /* -------------------------------------------------------------------------- */
    let weekdays = weekdays
    if weekdays == auto {
      weekdays = ("M", "T", "W", "T", "F", "S", "S")
    }
    assert(
      weekdays == none or (type(weekdays) == array and weekdays.len() == 7),
      message: "invalid value for 'weekdays', expected `none` or a array with 7 elements",
    )
    /* -------------------------------------------------------------------------- */

    let data-start-dt = start-date
    let data-end-dt = end-date

    if data-start-dt == auto {
      let min-date = datetime(year: 5000, month: 12, day: 31)
      for entry in data {
        for span in entry.spans {
          if span.start < min-date {
            min-date = span.start
          }
        }
      }

      data-start-dt = min-date
    }

    if data-end-dt == auto {
      let max-date = datetime(year: 1900, month: 1, day: 1)
      for entry in data {
        for span in entry.spans {
          if span.end > max-date {
            max-date = span.end
          }
        }
      }

      data-end-dt = max-date
    }

    assert(type(data-start-dt) == datetime, message: "'start-date' is expected to be a datetime")
    assert(type(data-end-dt) == datetime, message: "'end-date' is expected to be a datetime")

    let visible-start-dt = data-start-dt - date-padding
    let visible-end-dt = data-end-dt + date-padding

    let DATES = (
      visible-start: visible-start-dt,
      visible-end: visible-end-dt,
      data-start: data-start-dt,
      data-end: data-end-dt,
    )

    /* -------------------------------------------------------------------------- */
    let ticks = ticks
    if type(ticks) == int {
      let tick-duration = (data-end-dt - data-start-dt) / (ticks - 1)
      ticks = range(0, ticks).map(i => data-start-dt + i * tick-duration)
    } else if type(ticks) == function {
      ticks = ticks(DATES)
    }
    assert(type(ticks) == array)
    /* -------------------------------------------------------------------------- */
    let bookmarks = bookmarks
    if type(bookmarks) == function {
      bookmarks = bookmarks(DATES)
    }
    assert(type(bookmarks) == array)
    /* -------------------------------------------------------------------------- */

    let labels-width = 0pt
    if label-side != none {
      for e in data {
        if "label" in e {
          let (width,) = measure(e.label)
          if width > labels-width {
            labels-width = width
          }
        }
      }
    }
    labels-width += LABEL-PADDING
    if label-side == "both" {
      labels-width *= 2
    }

    /* -------------------------------------------------------------------------- */

    let UNIT-PER-DAYS = (width - labels-width) / (visible-end-dt - visible-start-dt).days()

    let dt-to-x(dt, start: visible-start-dt) = (dt - start).days() * UNIT-PER-DAYS

    let is-date-visible(dt) = dt >= visible-start-dt and dt <= visible-end-dt

    let bar(start, end, y, ..params) = {
      let a = dt-to-x(start)
      let b = dt-to-x(end, start: start)
      rect((a, y), (rel: (b, span-height)), anchor: "north", ..params)
    }

    let RIGHT = dt-to-x(visible-end-dt)

    /* -------------------------------------------------------------------------- */

    // Display the "kebabs"
    // The y-axis is rendered from "0" toward negative values
    // so that "kebabs" are ordered top to bottom
    for (i, entry) in data.enumerate() {
      let y = -i * vertical-padding

      if "label" in entry {
        if label-side == "both" or label-side == "left" {
          content(
            (0, y),
            anchor: "east",
            padding: (right: LABEL-PADDING),
            entry.label,
          )
        }
        if label-side == "both" or label-side == "right" {
          content(
            (RIGHT, y),
            anchor: "west",
            padding: (left: LABEL-PADDING),
            entry.label,
          )
        }
      }

      line((0, y), (RIGHT, y), stroke: (dash: "dashed", thickness: 0.5pt))

      for span in entry.spans {
        let fill = span.at("fill", default: auto)
        let stroke = span.at("stroke", default: auto)
        bar(
          span.start,
          span.end,
          y,
          fill: fill,
          stroke: stroke,
        )
      }
    }

    /* -------------------------------------------------------------------------- */

    // Reset the origin so that to bottomest "kebab" is near "0"
    let n = data.len()
    let TOP = (n + 1) * vertical-padding
    set-origin((0, -(n - 0.5) * vertical-padding - 0.5))

    // Display the vertical and horizontals axes
    line((0, 0), (0, TOP))
    line((0, 0), (RIGHT, 0))
    line((RIGHT, 0), (RIGHT, TOP))

    /* -------------------------------------------------------------------------- */

    for tick in ticks {
      let dt
      let tick-content
      let color

      if type(tick) == datetime {
        dt = tick
        tick-content = dt.display(date-format)
        color = auto
      } else if type(tick) == dictionary {
        dt = tick.at("date")
        tick-content = tick.at("content")
        color = tick.at("color", default: auto)
      } else {
        panic("invalid tick")
      }

      if not is-date-visible(dt) {
        continue
      }

      let x = dt-to-x(dt)

      move-to((x, 0))
      line(
        (rel: (0, -0.2)),
        (rel: (0, 0.4)),
        stroke: (paint: color),
      )
      content((x, 0), anchor: "north", padding: (top: 0.4cm), tick-content)
    }

    /* -------------------------------------------------------------------------- */

    // Display the bookmarks
    for mark in bookmarks {
      // assert the bookmark is visible
      if type(mark.date) == datetime {
        if not is-date-visible(mark.date) {
          continue
        }
      } else {
        let (start, end) = mark.date
        if end <= visible-start-dt or start >= visible-end-dt {
          continue
        }
      }

      let layer = mark.at("position", default: auto)
      let layer = if layer == "below" { -1 } else { 1 }

      on-layer(layer, {
        if type(mark.date) == datetime {
          let x = dt-to-x(mark.date)
          line((x, 0), (x, TOP), stroke: mark.at("stroke", default: auto))
          if "content" in mark {
            content(
              (x, TOP),
              anchor: "south",
              padding: (bottom: 0.15cm),
              mark.content,
            )
          }
        } else {
          let (start, end) = mark.date
          if start < visible-start-dt {
            start = visible-start-dt
          }
          if end > visible-end-dt {
            end = visible-end-dt
          }

          let start = dt-to-x(start)
          let end = dt-to-x(end)
          rect(
            (start, 0),
            (end, TOP),
            fill: mark.at("fill", default: auto),
            stroke: mark.at("stroke", default: auto),
          )
        }
      })
    }

    /* -------------------------------------------------------------------------- */

    if weekdays != none {
      let i = visible-start-dt

      while i < visible-end-dt {
        let a = dt-to-x(i)
        let b = dt-to-x(i + duration(days: 1))

        rect(
          (a, TOP),
          (b, TOP + 0.4),
        )
        content(
          ((a + b) / 2, TOP + 0.2),
          text(size: .7em, weekdays.at(i.weekday() - 1)),
        )

        i += duration(days: 1)
      }
    }

    /* -------------------------------------------------------------------------- */
  })
}
