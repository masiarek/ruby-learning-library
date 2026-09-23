# The Python twin: datetime (aware or naive), date and timedelta, on the same
# fixed instants. TZ is pinned to UTC before any local time is made.
import os
import time

os.environ["TZ"] = "UTC"
time.tzset()

import calendar
from datetime import date, datetime, timedelta, timezone


def row(n, text, value=""):
    print(f"{n:2d}. {text:<58} {value}")


t = datetime(2024, 2, 29, 12, tzinfo=timezone.utc)
row(1, "datetime(2024, 2, 29, 12, tzinfo=timezone.utc); type; aware?; tzname", f"{t}; {type(t).__name__}; {t.tzinfo is not None}; {t.tzname()}")
later = t + timedelta(days=1)
row(2, "+ timedelta(days=1); later - t is a timedelta", f"{later}; {later - t} ({type(later - t).__name__}); total_seconds={(later - t).total_seconds()}")
row(3, "+ timedelta(seconds=0.5) keeps microseconds; microsecond", f"{t + timedelta(seconds=0.5)}; {(t + timedelta(seconds=0.5)).microsecond}")
row(4, 'strftime("%Y-%m-%d %H:%M:%S %z"); ("%A %d %B %Y")', f"{t.strftime('%Y-%m-%d %H:%M:%S %z')}; {t.strftime('%A %d %B %Y')}")
row(5, 'strftime("%j %U %u %I %p")  (%-d and %e depend on the C library)', t.strftime("%j %U %u %I %p"))
row(6, "isoformat() writes +00:00, never Z; timespec=", f"{t.isoformat()}; {t.isoformat(timespec='milliseconds')}")
row(7, "timestamp() is a float; int() of it", f"{t.timestamp()}; {int(t.timestamp())}")
row(8, "fromtimestamp(0) is naive local; tz=timezone.utc makes it aware", f"{datetime.fromtimestamp(0)}; {datetime.fromtimestamp(0).tzinfo}; {datetime.fromtimestamp(0, tz=timezone.utc)}")
naive = datetime(2024, 2, 29, 12)
try:
    naive < t
    ordered = "ordered"
except TypeError as e:
    ordered = type(e).__name__
row(9, "datetime(2024, 2, 29, 12) is naive: tzinfo; == t; < t", f"{naive}; {naive.tzinfo}; {naive == t}; {ordered}")
plus2 = datetime(2024, 2, 29, 12, tzinfo=timezone(timedelta(hours=2)))
row(10, "tzinfo=timezone(timedelta(hours=2)); astimezone(utc); utcoffset; == t", f"{plus2}; {plus2.astimezone(timezone.utc)}; {plus2.utcoffset()}; {plus2 == t}")
g = t.astimezone(timezone(timedelta(hours=2)))
row(11, "t.astimezone(+02:00) is the same instant shown elsewhere", f"{g}; hour={g.hour}; == t: {g == t}")
row(12, "t < t + 1s; == with an equal datetime; hash equal; is", f"{t < t + timedelta(seconds=1)}; {t == datetime(2024, 2, 29, 12, tzinfo=timezone.utc)}; {hash(t) == hash(datetime(2024, 2, 29, 12, tzinfo=timezone.utc))}; {t is datetime(2024, 2, 29, 12, tzinfo=timezone.utc)}")
errors = []
for args in ((2024, 2, 30), (2024, 2, 29, 25)):
    try:
        datetime(*args)
    except ValueError as e:
        errors.append(type(e).__name__)
row(13, "datetime(2024, 2, 30) and hour 25 both raise", "; ".join(errors))
row(14, "replace(microsecond=0) instead of round; timetuple()[:6]", f"{(t + timedelta(seconds=0.5)).replace(microsecond=0)}; {t.timetuple()[:6]}")
row(15, "fromisoformat, strptime and strftime need no import", f"{hasattr(datetime, 'fromisoformat')}, {hasattr(datetime, 'strptime')}")
row(16, 'fromisoformat("...+02:00").astimezone(utc); strptime is naive', f"{datetime.fromisoformat('2024-02-29T12:00:00+02:00').astimezone(timezone.utc)}; {datetime.strptime('29/02/2024', '%d/%m/%Y')}")
row(17, 'fromisoformat accepts a trailing Z (3.11+)', str(datetime.fromisoformat("2024-02-29T12:00:00Z")))

d = date(2024, 1, 31)


def add_months(day, n):
    year, month = divmod(day.month - 1 + n, 12)
    year += day.year
    month += 1
    return day.replace(year=year, month=month, day=min(day.day, calendar.monthrange(year, month)[1]))


row(18, "date(2024, 1, 31); + timedelta(days=1); no month arithmetic: a helper", f"{d}; {d + timedelta(days=1)}; {add_months(d, 1)}; {add_months(d, 13)}; {add_months(d, -1)}")
diff = d - date(2024, 1, 1)
row(19, "date - date is a timedelta", f"{diff!r} ({type(diff).__name__}); days={diff.days}")
row(20, "strptime(...).date(), date.fromisoformat, strptime", f"{datetime.strptime('March 1, 2024', '%B %d, %Y').date()}; {date.fromisoformat('2024-03-01')}; {datetime.strptime('01/03/2024', '%d/%m/%Y').date()}")
try:
    date(2024, 2, 30)
    date_err = "built"
except ValueError as e:
    date_err = type(e).__name__
row(21, "calendar.isleap(2024, 2100, 2000); no valid_date; date(2024, 2, 30)", f"{[calendar.isleap(2024), calendar.isleap(2100), calendar.isleap(2000)]}; n/a; {date_err}")
row(22, "weekday() (Monday=0), isoweekday() (Monday=1), tm_yday, week; day_name", f"{d.weekday()}; {d.isoweekday()}; {d.timetuple().tm_yday}; {d.isocalendar().week}; {calendar.day_name[d.weekday()]}")
row(23, "no negative day: calendar.monthrange(y, m)[1] is the last day", f"{date(2024, 2, calendar.monthrange(2024, 2)[1])}; {date(2023, 2, calendar.monthrange(2023, 2)[1])}")
row(24, "a list of dates by timedelta; a stride", f"{[str(date(2024, 1, 1) + timedelta(days=i)) for i in range(3)]}; {[str(date(2024, 1, 1) + timedelta(days=i)) for i in range(0, 10, 3)]}")
row(25, "datetime.combine(d, time()) is naive midnight; t.date()", f"{datetime.combine(d, datetime.min.time())}; {t.date()} ({type(t.date()).__name__})")
row(26, "one datetime class does both jobs; no DateTime split", "n/a")
match t:
    case datetime(year=2024, month=2 | 3, hour=hour):
        matched = f"matched, hour={hour}"
row(27, "class patterns read attributes: case datetime(year=2024, ...)", f"n/a (no deconstruct_keys); {matched}")
