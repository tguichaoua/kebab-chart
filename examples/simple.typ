#import "../src/lib.typ": kebab-chart

#set page(width: auto, height: auto, margin: 0.5cm)

#kebab-chart(
  ticks: 5,

  (
    (
      spans: (
        (start: datetime(year: 2025, month: 1, day: 1), end: datetime(year: 2025, month: 1, day: 10)),
        (start: datetime(year: 2025, month: 2, day: 2), end: datetime(year: 2025, month: 2, day: 7)),
      ),
    ),
    (
      spans: (
        (start: datetime(year: 2025, month: 1, day: 7), end: datetime(year: 2025, month: 1, day: 17)),
        (start: datetime(year: 2025, month: 1, day: 28), end: datetime(year: 2025, month: 2, day: 9)),
      ),
    ),
  ),
)
