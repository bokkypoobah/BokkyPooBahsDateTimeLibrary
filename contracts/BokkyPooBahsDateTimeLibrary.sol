pragma solidity ^0.4.23;

contract BokkyPooBahsDateTimeLibrary {

    // 1801 <= year <= 2099
    // 1 <= mm <= 12
    // 1 <= dd <= 31
    // days = dd
    //      - 32075
    //      + 1461 * (yyyy + 4800 + (mm - 14) / 12) / 4
    //      + 367 * (mm - 2 - (mm - 14) / 12 * 12) / 12
    //      - 3 * ((yyyy + 4900 + (mm - 14) / 12) / 100) / 4
    function dddFromYYYYMMDD(int yyyy, int mm, int dd) public pure returns (int ddd) {
        ddd = dd
          - 32075
          + 1461 * (yyyy + 4800 + (mm - 14) / 12) / 4
          + 367 * (mm - 2 - (mm - 14) / 12 * 12) / 12
          - 3 * ((yyyy + 4900 + (mm - 14) / 12) / 100) / 4;
    }

    // int L = ddd + 68569
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // yyyy = 4000 * (L + 1) / 1461001
    // L = L - 1461 * yyyy / 4 + 31
    // mm = 80 * L / 2447
    // dd = L - 2447 * mm / 80
    // L = mm / 11
    // mm = mm + 2 - 12 * mm
    // yyyy = 100 * (N - 49) + yyyy + L

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
    function dddToYYYYMMDD(int ddd) public pure returns (int yyyy, int mm, int dd) {
        int L = ddd + 68569;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        yyyy = 4000 * (L + 1) / 1461001;
        L = L - 1461 * yyyy / 4 + 31;
        mm = 80 * L / 2447;
        dd = L - 2447 * mm / 80;
        L = mm / 11;
        mm = mm + 2 - 12 * L;
        yyyy = 100 * (N - 49) + yyyy + L;
    }

}