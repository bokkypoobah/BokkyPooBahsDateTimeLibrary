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
// Tested date range 1970/01/01 to 2222/12/31
//
// 1970 <= year  <= 2099
//    1 <= month <= 12
//    1 <= day   <= 31
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
    int public constant OFFSET19700101 = 2440588;

    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        return daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * 60 * 60 + minute * 60 + second;
    }

    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / 60 / 60;
        secs = secs % (60 * 60);
        minute = secs / 60;
        second = secs % 60;
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