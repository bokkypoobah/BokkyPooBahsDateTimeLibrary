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

    function timestampFromYYYYMMDD(uint yyyy, uint mm, uint dd) public pure returns (uint timestamp) {
        return dddFromYYYYMMDD(yyyy, mm, dd) * SECONDS_PER_DAY;
    }

    function timestampFromYYYYMMDDHHMMSS(uint yyyy, uint mm, uint dd, uint hh, uint min, uint ss) public pure returns (uint timestamp) {
        return dddFromYYYYMMDD(yyyy, mm, dd) * SECONDS_PER_DAY + hh * 60 * 60 + min * 60 + ss;
    }

    function timestampToYYYYMMDD(uint timestamp) public pure returns (uint yyyy, uint mm, uint dd) {
        (yyyy, mm, dd) = dddToYYYYMMDD(timestamp / SECONDS_PER_DAY);
    }

    function timestampToYYYYMMDDHHMMSS(uint timestamp) public pure returns (uint yyyy, uint mm, uint dd, uint hh, uint min, uint ss) {
        (yyyy, mm, dd) = dddToYYYYMMDD(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hh = secs / 60 / 60;
        secs = secs % (60 * 60);
        min = secs / 60;
        ss = secs % 60;
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
    function dddFromYYYYMMDD(uint yyyy, uint mm, uint dd) internal pure returns (uint ddd) {
        int _yyyy = int(yyyy);
        int _mm = int(mm);
        int _dd = int(dd);

        int _ddd = _dd
          - 32075
          + 1461 * (_yyyy + 4800 + (_mm - 14) / 12) / 4
          + 367 * (_mm - 2 - (_mm - 14) / 12 * 12) / 12
          - 3 * ((_yyyy + 4900 + (_mm - 14) / 12) / 100) / 4
          - 2440588;

        ddd = uint(_ddd);
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
    function dddToYYYYMMDD(uint ddd) internal pure returns (uint yyyy, uint mm, uint dd) {
        int _ddd = int(ddd);

        int L = _ddd + 68569 + 2440588;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _yyyy = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _yyyy / 4 + 31;
        int _mm = 80 * L / 2447;
        int _dd = L - 2447 * _mm / 80;
        L = _mm / 11;
        _mm = _mm + 2 - 12 * L;
        _yyyy = 100 * (N - 49) + _yyyy + L;

        yyyy = uint(_yyyy);
        mm = uint(_mm);
        dd = uint(_dd);
    }

}