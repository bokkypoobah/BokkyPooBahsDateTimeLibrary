pragma solidity ^0.4.23;

contract BokkyPooBahsDateTimeLibrary {

    function dddFromYYYYMMDD(uint yyyy, uint mm, uint dd) public pure returns (uint ddd) {
        return yyyy + mm + dd;
    }

    function dddToYYYYMMDD(uint ddd) public pure returns (uint yyyy, uint mm, uint dd) {
        yyyy = ddd % 123;
        mm = 2;
        dd = 3;
    }

}