pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Using the date conversion algorithms from
//   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
// And adding an offset of 2440588 so that 1970/01/01 is day 0. Then
// multiplying by seconds in a day to handle the Unix timestamp format
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
//
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint public constant SECONDS_PER_MINUTE = 60;
    uint public constant SECONDS_PER_HOUR = 60 * 60;
    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
    int public constant OFFSET19700101 = 2440588;

    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        return daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }
    function isLeapYear(uint year) public pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function getDaysInMonth(uint year, uint month) public pure returns (uint dim) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            dim = 31;
        } else if (month != 2) {
            dim = 30;
        } else {
            dim = isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) public pure returns (uint dow) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dow = (_days + 3) % 7 + 1;
    }
    function getYear(uint timestamp) public pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) public pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) public pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) public pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) public pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) public pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    // ------------------------------------------------------------------------
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
}