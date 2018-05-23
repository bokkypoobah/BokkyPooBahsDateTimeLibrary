pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Using the date conversion algorithms from
//   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
//
// And adding an offset of 2440588 so that 1970/01/01 is day 0
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// ----------------------------------------------------------------------------

contract BokkyPooBahsDateTimeLibrary {

    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;

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
    // 1970 <= year <= 2099
    // 1 <= mm <= 12
    // 1 <= dd <= 31
    // days = dd
    //      - 32075
    //      + 1461 * (yyyy + 4800 + (mm - 14) / 12) / 4
    //      + 367 * (mm - 2 - (mm - 14) / 12 * 12) / 12
    //      - 3 * ((yyyy + 4900 + (mm - 14) / 12) / 100) / 4
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
          - 2440588;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // int L = ddd + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // yyyy = 4000 * (L + 1) / 1461001
    // L = L - 1461 * yyyy / 4 + 31
    // mm = 80 * L / 2447
    // dd = L - 2447 * mm / 80
    // L = mm / 11
    // mm = mm + 2 - 12 * L
    // yyyy = 100 * (N - 49) + yyyy + L
    // ------------------------------------------------------------------------
    // L= JD+68569
    // N= 4*L/146097
    // L= L-(146097*N+3)/4
    // I= 4000*(L+1)/1461001
    // L= L-1461*I/4+31
    // J= 80*L/2447
    // K= L-2447*J/80
    // L= J/11
    // J= J+2-12*L
    // I= 100*(N-49)+I+L
    //
    // YEAR= I
    // MONTH= J
    // DAY= K
    function daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + 2440588;
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