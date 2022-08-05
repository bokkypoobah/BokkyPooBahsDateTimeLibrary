// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// ----------------------------------------------------------------------------
// Lookup table for BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// ----------------------------------------------------------------------------

import { Strings } from './utils/Strings.sol';
import { BokkyPooBahsDateTimeLibrary } from './BokkyPooBahsDateTimeLibrary.sol';


contract BokkyPooBahsDateTimeLookup {
    using Strings for uint256;
    using BokkyPooBahsDateTimeLibrary for uint256;

    // Outputs timestamp to short date format with year (2nd Dec 2022)
    function timestampToDayMonYear(uint timestamp) public pure returns (string memory) {
        (uint year, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        return string(abi.encodePacked(dayOfMonthString(day), ' ', monthStringShort(month), ' ', year.toString()));
    }

    // Outputs timestamp to long date format with year (2nd December 2022)
    function timestampToDayMonthYear(uint timestamp) public pure returns (string memory) {
        (uint year, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        return string(abi.encodePacked(dayOfMonthString(day), ' ', monthStringLong(month), ' ', year.toString()));
    }

    // Outputs timestamp to short date format (2nd Dec)
    function timestampToDayMon(uint timestamp) public pure returns (string memory) {
        (, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        return string(abi.encodePacked(dayOfMonthString(day), ' ', monthStringShort(month)));
    }

    // Outputs timestamp to long date format (2nd December)
    function timestampToDayMonth(uint timestamp) public pure returns (string memory) {
        (, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        return string(abi.encodePacked(dayOfMonthString(day), ' ', monthStringLong(month)));
    }

    // Converts months to string (2 -> February)
    function monthStringLong (uint month) public pure returns (string memory) {
        if (month == 1) return "January";
        if (month == 2) return "February";
        if (month == 3) return "March";
        if (month == 4) return "April";
        if (month == 5) return "May";
        if (month == 6) return "June";
        if (month == 7) return "July";
        if (month == 8) return "August";
        if (month == 9) return "September";
        if (month == 10) return "October";
        if (month == 11) return "November";
        if (month == 12) return "December";
        return "";
    }

    // Converts months to short string (2 -> Feb)
    function monthStringShort (uint month) public pure returns (string memory) {
        if (month == 1) return "Jan";
        if (month == 2) return "Feb";
        if (month == 3) return "Mar";
        if (month == 4) return "Apr";
        if (month == 5) return "May";
        if (month == 6) return "Jun";
        if (month == 7) return "Jul";
        if (month == 8) return "Aug";
        if (month == 9) return "Sep";
        if (month == 10) return "Oct";
        if (month == 11) return "Nov";
        if (month == 12) return "Dec";
        return "";
    }

    // Converts day of month to string (21 -> 21st)
    function dayOfMonthString (uint dayOfMonth) public pure returns (string memory) {
        if (dayOfMonth == 1) return "1st";
        if (dayOfMonth == 2) return "2nd";
        if (dayOfMonth == 3) return "3rd";
        if (dayOfMonth == 21) return "21st";
        if (dayOfMonth == 22) return "22nd";
        if (dayOfMonth == 23) return "23rd";
        if (dayOfMonth == 31) return "31st";
        if (dayOfMonth > 3 && dayOfMonth < 31) {
            return string(abi.encodePacked(dayOfMonth.toString(), 'th'));
        }
        return "";
    }

}
