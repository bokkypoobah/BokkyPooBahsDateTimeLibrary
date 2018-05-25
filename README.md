# BokkyPooBah's DateTime Library

**Status: Work in progress**

A gas-efficient Solidity date and time library.

Instead of using loops and lookup tables, this date conversions library uses formulae to convert year/month/day hour:minute:second to a Unix timestamp and back.

<br />

<hr />

## Table Of Contents

* [History](#history)
* [Conventions](#conventions)
* [Functions](#functions)
  * [_daysFromDate](#_daysfromdate)
  * [_daysToDate](#_daystodate)
  * [timestampFromDate](#timestampfromdate)
  * [timestampFromDateTime](#timestampfromdatetime)
  * [timestampToDate](#timestamptodate)
  * [timestampToDateTime](#timestamptodatetime)
  * [isLeapYear](#isleapyear)
  * [_isLeapYear](#_isleapyear)
  * [isWeekDay](#isweekday)
  * [isWeekEnd](#isweekend)
  * [getDaysInMonth](#getdaysinmonth)
  * [_getDaysInMonth](#_getdaysinmonth)
  * [getDayOfWeek](#getdayofweek)
  * [getYear](#getyear)
  * [getMonth](#getmonth)
  * [getDay](#getday)
  * [getHour](#gethour)
  * [getMinute](#getminute)
  * [getSecond](#getsecond)
  * [addYears](#addyears)
  * [addMonths](#addmonths)
  * [addDays](#adddays)
  * [addHours](#addhours)
  * [addMinutes](#addminutes)
  * [addSeconds](#addseconds)
  * [subYears](#subyears)
  * [subMonths](#submonths)
  * [subDays](#subdays)
  * [subHours](#subhours)
  * [subMinutes](#subminutes)
  * [subSeconds](#subseconds)
  * [diffDays](#diffdays)
  * [diffMonths](#diffmonths)
  * [diffYears](#diffyears)
* [Gas Cost](#gas-cost)
* [Algorithm](#algorithm)
* [Testing](#testing)

<br />

<hr />

## History

Version  | Date         | Notes
:------- |:------------ |:-----------------------------
v1.00    | May 25 2018  | First release (currently WIP)

<br />

<hr />

## Conventions

All dates, times and Unix timestamps are [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

Unit           | Range                     | Notes
:------------- |:-------------------------:|:---------------------------------------------------------------
timestamp      | >= 0                      | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
year           | 1970 ... 2345             |
month          | 1 ... 12                  |
day            | 1 ... 31                  |
hour           | 0 ... 23                  |
minute         | 0 ... 59                  |
second         | 0 ... 59                  |
dayOfWeek      | 1 ... 7                   | 1 = Monday, ..., 7 = Sunday
year/month/day | 1970/01/01 ... 2345/12/31 |

`_days`, `_months` and `_years` variable names are `_`-prefixed as the non-prefixed versions are reserve words in Solidity.

All functions operate on the `uint` timestamp data type, except for functions prefixed with `_`.

<br />

<hr />

## Functions

### _daysFromDate

Calculate the number of days `_days` from 1970/01/01 to `year`/`month`/`day`

```javascript
function _daysFromDate(uint year, uint month, uint day) public pure returns (uint _days)
```

<br />

### _daysToDate

Calculate `year`/`month`/`day` from the number of days `_days` since 1970/01/01

```javascript
function _daysToDate(uint _days) public pure returns (uint year, uint month, uint day)
```

<br />

### timestampFromDate

Calculate the `timestamp` to `year`/`month`/`day`

```javascript
function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp)
```

<br />

### timestampFromDateTime

Calculate the `timestamp` to `year`/`month`/`day` `hour`:`minute`:`second` UTC

```javascript
function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp)
```

<br />

### timestampToDate

Calculate `year`/`month`/`day` from `timestamp`

```javascript
function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day)
```

<br />

### timestampToDateTime

Calculate `year`/`month`/`day` `hour`:`minute`:`second` from `timestamp`

```javascript
function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second)
```

<br />

### isLeapYear

Is the year specified by `timestamp` a leap year?

```javascript_
function isLeapYear(uint timestamp) public pure returns (bool leapYear)
```

<br />

### _isLeapYear

Is the specified `year` (e.g. 2018) a leap year?

```javascript_
function _isLeapYear(uint year) public pure returns (bool leapYear)
```

<br />

### isWeekDay

Is the day specified by `timestamp` a weekday (Monday, ..., Friday)?

```javascript
function isWeekDay(uint timestamp) public pure returns (bool weekDay)
```

<br />

### isWeekEnd

Is the day specified by `timestamp` a weekend (Saturday, Sunday)?

```javascript
function isWeekEnd(uint timestamp) public pure returns (bool weekEnd)
```

<br />

### getDaysInMonth

Return the day in the month `daysInMonth` for the month specified by `timestamp`

```javascript
function getDaysInMonth(uint timestamp) public pure returns (uint daysInMonth)
```

<br />

### _getDaysInMonth

Return the day in the month `daysInMonth` (1, ..., 31) for the month specified by the `year`/`month`

```javascript
function _getDaysInMonth(uint year, uint month) public pure returns (uint daysInMonth)
```

<br />

### getDayOfWeek

Return the day of the week `dayOfWeek` (1 = Monday, ..., 7 = Sunday) for the date specified by `timestamp`

```javascript
function getDayOfWeek(uint timestamp) public pure returns (uint dayOfWeek)
```

<br />

### getYear

Get the `year` of the date specified by `timestamp`

```javascript
function getYear(uint timestamp) public pure returns (uint year)
```

<br />

### getMonth

Get the `month` of the date specified by `timestamp`

```javascript
function getMonth(uint timestamp) public pure returns (uint month)
```

<br />

### getDay

Get the day of the month `day` (1, ..., 31) of the date specified `timestamp`

```javascript
function getDay(uint timestamp) public pure returns (uint day)
```

<br />

### getHour

Get the `hour` of the date and time specified by `timestamp`

```javascript
function getHour(uint timestamp) public pure returns (uint hour)
```

<br />

### getMinute

Get the `minute` of the date and time specified by `timestamp`

```javascript
function getMinute(uint timestamp) public pure returns (uint minute)
```

<br />

### getSecond

Get the `second` of the date and time specified by `timestamp`

```javascript
function getSecond(uint timestamp) public pure returns (uint second)
```

<br />

### addYears

```javascript
function addYears(uint timestamp, uint _years) public pure returns (uint newTimestamp)
```

<br />

### addMonths

```javascript
function addMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp)
```

<br />

### addDays

```javascript
function addDays(uint timestamp, uint _days) public pure returns (uint newTimestamp)
```

<br />

### addHours

```javascript
function addHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp)
```

<br />

### addMinutes

```javascript
function addMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp)
```

<br />

### addSeconds

```javascript
function addSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp)
```

<br />

### subYears

```javascript
function subYears(uint timestamp, uint _years) public pure returns (uint newTimestamp)
```

<br />

### subMonths

```javascript
function subMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp)
```

<br />

### subDays

```javascript
function subDays(uint timestamp, uint _days) public pure returns (uint newTimestamp)
```

<br />

### subHours

```javascript
function subHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp)
```

<br />

### subMinutes

```javascript
function subMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp)
```

<br />

### subSeconds

```javascript
function subSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp)
```

<br />

### diffDays

```javascript
function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days)
```

<br />

### diffMonths

```javascript
function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months)
```

<br />

### diffYears

```javascript
function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years)
```

<br />

<hr />

## Gas Cost

### `timestampToDateTime(...)` Gas Cost

From executing the following function, the transaction gas cost is 24,693

```javascript
> testDateTime.timestampToDateTime(1527120000)
[2018, 5, 24, 0, 0, 0]
> testDateTime.timestampToDateTime.estimateGas(1527120000)
24693
```

From Remix, the execution gas cost is 3,101.

<br />

### `timestampFromDateTime(...)` Gas Cost

From executing the following function, the transaction gas cost is 25,054

```javascript
> testDateTime.timestampFromDateTime(2018, 05, 24, 1, 2, 3)
1527123723
> testDateTime.timestampFromDateTime.estimateGas(2018, 05, 24, 1, 2, 3)
25054
```

From Remix, the execution gas cost is 2,566

<br />

<hr />

## Algorithm

The formulae to convert year/month/day hour:minute:second to a Unix timestamp and back use the algorithms from [Converting Between Julian Dates and Gregorian Calendar Dates](http://aa.usno.navy.mil/faq/docs/JD_Formula.php).

Note that these algorithms depend on negative numbers, so Solidity unsigned integers `uint` are converted to signed integers `int` to compute the date conversions and the results are converted back to `uint` for general use.

<br />

### Converting YYYYMMDD to Unix Timestamp

The Fortran algorithm follows:

```
    INTEGER FUNCTION JD (YEAR,MONTH,DAY)
C
C---COMPUTES THE JULIAN DATE (JD) GIVEN A GREGORIAN CALENDAR
C   DATE (YEAR,MONTH,DAY).
C
    INTEGER YEAR,MONTH,DAY,I,J,K
C
    I= YEAR
    J= MONTH
    K= DAY
C
    JD= K-32075+1461*(I+4800+(J-14)/12)/4+367*(J-2-(J-14)/12*12)
   2    /12-3*((I+4900+(J-14)/12)/100)/4
C
    RETURN
    END
```

Translating this formula, and subtracting an offset (2,440,588) so 1970/01/01 is day 0:

```
days = day
     - 32075
     + 1461 * (year + 4800 + (month - 14) / 12) / 4
     + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
     - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
     - offset
```

<br />

### Converting Unix Timestamp To YYYYMMDD

The Fortran algorithm follows:

```
    SUBROUTINE GDATE (JD, YEAR,MONTH,DAY)
C
C---COMPUTES THE GREGORIAN CALENDAR DATE (YEAR,MONTH,DAY)
C   GIVEN THE JULIAN DATE (JD).
C
    INTEGER JD,YEAR,MONTH,DAY,I,J,K
C
    L= JD+68569
    N= 4*L/146097
    L= L-(146097*N+3)/4
    I= 4000*(L+1)/1461001
    L= L-1461*I/4+31
    J= 80*L/2447
    K= L-2447*J/80
    L= J/11
    J= J+2-12*L
    I= 100*(N-49)+I+L
C
    YEAR= I
    MONTH= J
    DAY= K
C
    RETURN
    END
 ```

Translating this formula and adding an offset (2,440,588) so 1970/01/01 is day 0:

```
int L = days + 68569 + offset
int N = 4 * L / 146097
L = L - (146097 * N + 3) / 4
year = 4000 * (L + 1) / 1461001
L = L - 1461 * year / 4 + 31
month = 80 * L / 2447
dd = L - 2447 * month / 80
L = month / 11
month = month + 2 - 12 * L
year = 100 * (N - 49) + year + L
```

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The DateTime library calculations have been tested for the date range 1970/01/01 to 2345/12/01 for periodically sampled dates.

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy [contracts/BokkyPooBahsDateTimeLibrary.sol](contracts/BokkyPooBahsDateTimeLibrary.sol) library
* [x] Deploy [contracts/TestDateTime.sol](contracts/TestDateTime.sol) contract
* [x] Test `_isLeapYear(...)`
* [x] Test `isWeekDay(...)`
* [x] Test `isWeekEnd(...)`
* [x] Test `_getDaysInMonth(...)`
* [x] Test `getDayOfWeek(...)`
* [x] Test `get{Year|Month|Day|Hour|Minute|Second}(...)`
* [x] Test `add{Years|Months|Days|Hours|Minutes|Seconds}(...)`
* [x] Test `sub{Years|Months|Days|Hours|Minutes|Seconds}(...)`
* [x] Test `diff{Days|Months|Years}(...)`
* [x] For a range of Unix timestamps from 1970/01/01 to 2345/12/21
  * [x] Generate the year/month/day hour/minute/second from the Unix timestamp using `timestampToDateTime(...)`
  * [x] Generate the Unix timestamp from the calculated year/month/day hour/minute/second using `timestampFromDateTime(...)`
  * [x] Compare the year/month/day hour/minute/second to the JavaScript *Date* calculation

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd - May 23 2018. [GNU Lesser General Public License 3.0](https://www.gnu.org/licenses/lgpl-3.0.en.html)