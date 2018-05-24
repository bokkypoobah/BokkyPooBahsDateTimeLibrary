pragma solidity ^0.4.23;

import "BokkyPooBahsDateTimeLibrary.sol";

// ----------------------------------------------------------------------------
// Testing BokkyPooBah's DateTime Library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

contract TestDateTime {
    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDateTime(year, month, day, hour, minute, second);
    }
    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }
    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
    }

    function isLeapYear(uint year) public pure returns (bool leapYear) {
        leapYear = BokkyPooBahsDateTimeLibrary.isLeapYear(year);
    }
    function getDaysInMonth(uint year, uint month) public pure returns (uint dim) {
        dim = BokkyPooBahsDateTimeLibrary.getDaysInMonth(year, month);
    }
    function getDayOfWeek(uint timestamp) public pure returns (uint dow) {
        dow = BokkyPooBahsDateTimeLibrary.getDayOfWeek(timestamp);
    }
    function getYear(uint timestamp) public pure returns (uint year) {
        year = BokkyPooBahsDateTimeLibrary.getYear(timestamp);
    }
    function getMonth(uint timestamp) public pure returns (uint month) {
        month = BokkyPooBahsDateTimeLibrary.getMonth(timestamp);
    }
    function getDay(uint timestamp) public pure returns (uint day) {
        day = BokkyPooBahsDateTimeLibrary.getDay(timestamp);
    }
    function getHour(uint timestamp) public pure returns (uint hour) {
        hour = BokkyPooBahsDateTimeLibrary.getHour(timestamp);
    }
    function getMinute(uint timestamp) public pure returns (uint minute) {
        minute = BokkyPooBahsDateTimeLibrary.getMinute(timestamp);
    }
    function getSecond(uint timestamp) public pure returns (uint second) {
        second = BokkyPooBahsDateTimeLibrary.getSecond(timestamp);
    }

    function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {
        _days = BokkyPooBahsDateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months) {
        _months = BokkyPooBahsDateTimeLibrary.diffMonths(fromTimestamp, toTimestamp);
    }
    function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years) {
        _years = BokkyPooBahsDateTimeLibrary.diffYears(fromTimestamp, toTimestamp);
    }
}