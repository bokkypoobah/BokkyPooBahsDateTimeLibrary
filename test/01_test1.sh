#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-full}

source settings
echo "---------- Settings ----------" | tee $TEST1OUTPUT
cat ./settings | tee -a $TEST1OUTPUT
echo "" | tee -a $TEST1OUTPUT

CURRENTTIME=`date +%s`
CURRENTTIMES=`perl -le "print scalar localtime $CURRENTTIME"`
START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`perl -le "print scalar localtime $START_DATE"`
END_DATE=`echo "$CURRENTTIME+60*2" | bc`
END_DATE_S=`perl -le "print scalar localtime $END_DATE"`

printf "MODE               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "DATETIMELIBSOL     = '$DATETIMELIBSOL'\n" | tee -a $TEST1OUTPUT
printf "DATETIMELIBJS      = '$DATETIMELIBJS'\n" | tee -a $TEST1OUTPUT
printf "TESTDATETIMESOL    = '$TESTDATETIMESOL'\n" | tee -a $TEST1OUTPUT
printf "TESTDATETIMEJS     = '$TESTDATETIMEJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $SOURCEDIR/$DATETIMELIBSOL .`
`cp $SOURCEDIR/$TESTDATETIMESOL .`

# --- Modify parameters ---
# `perl -pi -e "s/START_DATE \= 1525132800.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
# `perl -pi -e "s/endDate \= 1527811200;.*$/endDate \= $END_DATE; \/\/ $END_DATE_S/" $CROWDSALESOL`

DIFFS1=`diff $SOURCEDIR/$DATETIMELIBSOL $DATETIMELIBSOL`
echo "--- Differences $SOURCEDIR/$DATETIMELIBSOL $DATETIMELIBSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$TESTDATETIMESOL $TESTDATETIMESOL`
echo "--- Differences $SOURCEDIR/$TESTDATETIMESOL $TESTDATETIMESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.6.0 --version | tee -a $TEST1OUTPUT

echo "var dateTimeLibOutput=`solc_0.6.0 --optimize --pretty-json --combined-json abi,bin,interface $DATETIMELIBSOL`;" > $DATETIMELIBJS
echo "var testDateTimeOutput=`solc_0.6.0 --optimize --pretty-json --combined-json abi,bin,interface $TESTDATETIMESOL`;" > $TESTDATETIMEJS
../scripts/solidityFlattener.pl --contractsdir=../contracts --mainsol=$TESTDATETIMESOL --outputsol=$TESTDATETIMEFLATTENED --verbose | tee -a $TEST1OUTPUT

if [ "$MODE" = "compile" ]; then
  echo "Compiling only"
  exit 1;
fi

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$DATETIMELIBJS");
loadScript("$TESTDATETIMEJS");
loadScript("functions.js");

var dateTimeLibAbi = JSON.parse(dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].abi);
var dateTimeLibBin = "0x" + dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].bin;
var testDateTimeAbi = JSON.parse(testDateTimeOutput.contracts["$TESTDATETIMESOL:TestDateTime"].abi);
var testDateTimeBin = "0x" + testDateTimeOutput.contracts["$TESTDATETIMESOL:TestDateTime"].bin;

console.log("DATA: dateTimeLibAbi=" + JSON.stringify(dateTimeLibAbi));
console.log("DATA: dateTimeLibBin=" + JSON.stringify(dateTimeLibBin));
console.log("DATA: testDateTimeAbi=" + JSON.stringify(testDateTimeAbi));
console.log("DATA: testDateTimeBin=" + JSON.stringify(testDateTimeBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployDateTimeLibMessage = "Deploy DateTime Library";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployDateTimeLibMessage + " -----");
var dateTimeLibContract = web3.eth.contract(dateTimeLibAbi);
// console.log(JSON.stringify(dateTimeLibContract));
var dateTimeLibTx = null;
var dateTimeLibAddress = null;
var currentBlock = eth.blockNumber;
var dateTimeLib = dateTimeLibContract.new({from: contractOwnerAccount, data: dateTimeLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        dateTimeLibTx = contract.transactionHash;
      } else {
        dateTimeLibAddress = contract.address;
        addAccount(dateTimeLibAddress, "DateTime Library");
        console.log("DATA: var dateTimeLibAddress=\"" + dateTimeLibAddress + "\";");
        console.log("DATA: var dateTimeLibAbi=" + JSON.stringify(dateTimeLibAbi) + ";");
        console.log("DATA: var dateTimeLib=eth.contract(dateTimeLibAbi).at(dateTimeLibAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(dateTimeLibTx, deployDateTimeLibMessage);
printTxData("dateTimeLibTx", dateTimeLibTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testDateTimeMessage = "Deploy TestDateTime Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + testDateTimeMessage + " ----------");
// console.log("RESULT: testDateTimeBin='" + testDateTimeBin + "'");
var newTestDateTimeBin = testDateTimeBin.replace(/__BokkyPooBahsDateTimeLibrary\.sol\:Bokk__/g, dateTimeLibAddress.substring(2, 42));
// console.log("RESULT: newTestDateTimeBin='" + newTestDateTimeBin + "'");
var testDateTimeContract = web3.eth.contract(testDateTimeAbi);
var testDateTimeTx = null;
var testDateTimeAddress = null;
var testDateTime = testDateTimeContract.new({from: contractOwnerAccount, data: newTestDateTimeBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        testDateTimeTx = contract.transactionHash;
      } else {
        testDateTimeAddress = contract.address;
        addAccount(testDateTimeAddress, "TestDateTime");
        console.log("DATA: var testDateTimeAddress=\"" + testDateTimeAddress + "\";");
        console.log("DATA: var testDateTimeAbi=" + JSON.stringify(testDateTimeAbi) + ";");
        console.log("DATA: var testDateTime=eth.contract(testDateTimeAbi).at(testDateTimeAddress);");
        console.log("DATA: console.log(\"testDateTime=\" + JSON.stringify(testDateTime));");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(testDateTimeTx, testDateTimeMessage);
printTxData("testDateTimeAddress=" + testDateTimeAddress, testDateTimeTx);
console.log("RESULT: ");

var failureDetected = false;
var timestamp;
var newTimestamp;
var expectedTimestamp;
var fromTimestamp;
var toTimestamp;

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test isLeapYear ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2000, 5, 24, 1, 2, 3);
  if (!assert(testDateTime.isLeapYear.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a leap year")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2100, 5, 24, 1, 2, 3);
  if (!assert(!testDateTime.isLeapYear.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a not leap year")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2104, 5, 24, 1, 2, 3);
  if (!assert(testDateTime.isLeapYear.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a leap year")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test isValidDate and isValidDateTime.call ----------");
  if (!assert(testDateTime.isValidDate.call(1969, 1, 1) == false, "testDateTime.isValidDate.call(1969, 1, 1) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDate.call(1970, 1, 1) == true, "testDateTime.isValidDate.call(1970, 1, 1) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDate.call(2000, 2, 29) == true, "testDateTime.isValidDate.call(2000, 2, 29) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDate.call(2001, 2, 29) == false, "testDateTime.isValidDate.call(2001, 2, 29) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDate.call(2001, 0, 1) == false, "testDateTime.isValidDate.call(2001, 0, 1) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDate.call(2001, 1, 0) == false, "testDateTime.isValidDate.call(2001, 1, 0) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 0, 0, 0) == true, "testDateTime.isValidDateTime.call(2000, 2, 29, 0, 0, 0) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 1) == true, "testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 1) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 23, 1, 1) == true, "testDateTime.isValidDateTime.call(2000, 2, 29, 23, 1, 1) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 24, 1, 1) == false, "testDateTime.isValidDateTime.call(2000, 2, 29, 24, 1, 1) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 1, 59, 1) == true, "testDateTime.isValidDateTime.call(2000, 2, 29, 1, 59, 1) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 1, 60, 1) == false, "testDateTime.isValidDateTime.call(2000, 2, 29, 1, 60, 1) is false")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 59) == true, "testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 59) is true")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 60) == false, "testDateTime.isValidDateTime.call(2000, 2, 29, 1, 1, 60) is false")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test _isLeapYear ----------");
  if (!assert(testDateTime._isLeapYear.call(2000), "2000 is a leap year")) {
    failureDetected = true;
  }
  if (!assert(!testDateTime._isLeapYear.call(2100), "2100 is a not leap year")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._isLeapYear.call(2104), "2104 is a leap year")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test isWeekDay ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 24, 1, 2, 3);
  if (!assert(testDateTime.isWeekDay.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a week day")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 25, 1, 2, 3);
  if (!assert(testDateTime.isWeekDay.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a week day")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 26, 1, 2, 3);
  if (!assert(!testDateTime.isWeekDay.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a not week day")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test isWeekEnd ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 24, 1, 2, 3);
  if (!assert(!testDateTime.isWeekEnd.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a not a week end")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 25, 1, 2, 3);
  if (!assert(!testDateTime.isWeekEnd.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a not a week end")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 26, 1, 2, 3);
  if (!assert(testDateTime.isWeekEnd.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a week end")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 27, 1, 2, 3);
  if (!assert(testDateTime.isWeekEnd.call(timestamp), testDateTime.timestampToDateTime.call(timestamp) + " is a week end")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}


if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test getDaysInMonth ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2000, 1, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 2, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 29, testDateTime.timestampToDateTime.call(timestamp) + " has 29 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2001, 2, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 28, testDateTime.timestampToDateTime.call(timestamp) + " has 28 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 3, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 4, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 30, testDateTime.timestampToDateTime.call(timestamp) + " has 30 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 5, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 6, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 30, testDateTime.timestampToDateTime.call(timestamp) + " has 30 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 7, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 8, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 9, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 30, testDateTime.timestampToDateTime.call(timestamp) + " has 30 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 10, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 11, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 30, testDateTime.timestampToDateTime.call(timestamp) + " has 30 days")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 12, 24, 1, 2, 3);
  if (!assert(testDateTime.getDaysInMonth.call(timestamp) == 31, testDateTime.timestampToDateTime.call(timestamp) + " has 31 days")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}


if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test _getDaysInMonth ----------");
  if (!assert(testDateTime._getDaysInMonth.call(2000, 1) == 31, "2000/01 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 2) == 29, "2000/02 has 29 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2001, 2) == 28, "2001/02 has 28 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 3) == 31, "2000/03 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 4) == 30, "2000/04 has 30 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 5) == 31, "2000/05 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 6) == 30, "2000/06 has 30 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 7) == 31, "2000/07 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 8) == 31, "2000/08 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 9) == 30, "2000/09 has 30 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 10) == 31, "2000/10 has 31 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 11) == 30, "2000/11 has 30 days")) {
    failureDetected = true;
  }
  if (!assert(testDateTime._getDaysInMonth.call(2000, 12) == 31, "2000/12 has 31 days")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}


if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test getDayOfWeek ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 21, 1, 2, 3);
  if (!assert(testDateTime.getDayOfWeek.call(timestamp) == 1, testDateTime.timestampToDateTime.call(timestamp) + " is 1 Monday")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 24, 1, 2, 3);
  if (!assert(testDateTime.getDayOfWeek.call(timestamp) == 4, testDateTime.timestampToDateTime.call(timestamp) + " is 4 Thursday")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 26, 1, 2, 3);
  if (!assert(testDateTime.getDayOfWeek.call(timestamp) == 6, testDateTime.timestampToDateTime.call(timestamp) + " is 6 Saturday")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 27, 1, 2, 3);
  if (!assert(testDateTime.getDayOfWeek.call(timestamp) == 7, testDateTime.timestampToDateTime.call(timestamp) + " is 7 Sunday")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}


if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test get* ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2018, 5, 21, 1, 2, 3);
  if (!assert(testDateTime.getYear.call(timestamp) == 2018, testDateTime.timestampToDateTime.call(timestamp) + " year is 2018")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.getMonth.call(timestamp) == 5, testDateTime.timestampToDateTime.call(timestamp) + " month is 5 May")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.getDay.call(timestamp) == 21, testDateTime.timestampToDateTime.call(timestamp) + " day is 21")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.getHour.call(timestamp) == 1, testDateTime.timestampToDateTime.call(timestamp) + " hour is 1")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.getMinute.call(timestamp) == 2, testDateTime.timestampToDateTime.call(timestamp) + " minute is 2")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.getSecond.call(timestamp) == 3, testDateTime.timestampToDateTime.call(timestamp) + " second is 3")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test add{Years|Months|Days|Hours|Minutes|Seconds} ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2000, 2, 29, 1, 2, 3);
  newTimestamp = testDateTime.addYears.call(timestamp, 3);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2003, 2, 28, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 3 years is 2003/02/28 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 12, 31, 2, 3, 4);
  newTimestamp = testDateTime.addYears.call(timestamp, 30);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2048, 12, 31, 2, 3, 4);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 30 years is 2048/12/31 02:03:04")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 1, 31, 1, 2, 3);
  newTimestamp = testDateTime.addMonths.call(timestamp, 37);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2003, 2, 28, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 37 months is 2003/02/28 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 12, 1, 2, 3, 4);
  newTimestamp = testDateTime.addMonths.call(timestamp, 362);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2049, 2, 1, 2, 3, 4);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 362 months is 2049/02/01 02:03:04")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2017, 1, 31, 1, 2, 3);
  newTimestamp = testDateTime.addDays.call(timestamp, 37532);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2119, 11, 5, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 37,532 days is 2119/11/05 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2017, 1, 31, 1, 2, 3);
  newTimestamp = testDateTime.addHours.call(timestamp, 900768);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2119, 11, 5, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 900,768 hours is 2119/11/05 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2017, 1, 31, 1, 2, 3);
  newTimestamp = testDateTime.addMinutes.call(timestamp, 781920);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2018, 7, 28, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 781,920 minutes is 2018/07/28 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2017, 1, 31, 1, 2, 3);
  newTimestamp = testDateTime.addSeconds.call(timestamp, "461548800");
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2031, 9, 17, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " + 461,548,800 seconds is 2031/09/17 01:02:03")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test sub{Years|Months|Days|Hours|Minutes|Seconds} ----------");
  timestamp = testDateTime.timestampFromDateTime.call(2000, 2, 29, 1, 2, 3);
  newTimestamp = testDateTime.subYears.call(timestamp, 3);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(1997, 2, 28, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 3 years is 1997/02/28 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2000, 2, 29, 1, 2, 3);
  newTimestamp = testDateTime.subMonths.call(timestamp, 37);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(1997, 1, 29, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 37 months is 1997/01/29 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2013, 1, 1, 1, 2, 3);
  newTimestamp = testDateTime.subDays.call(timestamp, 3756);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2002, 9, 20, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 3,756 days is 2002/09/20 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2013, 1, 1, 1, 2, 3);
  newTimestamp = testDateTime.subHours.call(timestamp, 3756 * 24);
  expectedTimestamp = testDateTime.timestampFromDateTime.call(2002, 9, 20, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 3,756 * 24 hours is 2002/09/20 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2015, 7, 15, 1, 2, 3);
  newTimestamp = testDateTime.subHours.call(timestamp, "223776");
  expectedTimestamp = testDateTime.timestampFromDateTime.call(1990, 1, 3, 1, 2, 3);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 223,776 hours is 1990/01/03 01:02:03")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2018, 3, 1, 2, 3, 4);
  newTimestamp = testDateTime.subMinutes.call(timestamp, "21600000");
  expectedTimestamp = testDateTime.timestampFromDateTime.call(1977, 2, 4, 2, 3, 4);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 21,600,000 minutes is 1977/02/04 02:03:04")) {
    failureDetected = true;
  }
  timestamp = testDateTime.timestampFromDateTime.call(2020, 3, 19, 3, 4, 5);
  newTimestamp = testDateTime.subSeconds.call(timestamp, "788227200");
  expectedTimestamp = testDateTime.timestampFromDateTime.call(1995, 3, 28, 3, 4, 5);
  if (!assertIntEquals(newTimestamp, expectedTimestamp, testDateTime.timestampToDateTime.call(timestamp) + " - 788,227,200 seconds is 1995/03/28 03:04:05")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test diff{Years|Months|Days|Hours|Minutes|Seconds} ----------");
  fromTimestamp = testDateTime.timestampFromDateTime.call(2017, 10, 21, 1, 2, 3);
  console.log("RESULT: fromTimestamp=" + fromTimestamp + " " + testDateTime.timestampToDateTime.call(fromTimestamp));
  toTimestamp = testDateTime.timestampFromDateTime.call(2019, 7, 18, 4, 5, 6);
  console.log("RESULT: toTimestamp=" + toTimestamp + " " + testDateTime.timestampToDateTime.call(toTimestamp));

  if (!assert(testDateTime.diffYears.call(fromTimestamp, toTimestamp) == 2, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 2 years diff")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.diffMonths.call(fromTimestamp, toTimestamp) == 21, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 21 months diff")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.diffDays.call(fromTimestamp, toTimestamp) == 635, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 635 days diff")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.diffHours.call(fromTimestamp, toTimestamp) == 15243, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 15,243 hours diff")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.diffMinutes.call(fromTimestamp, toTimestamp) == 914583, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 914,583 minutes diff")) {
    failureDetected = true;
  }
  if (!assert(testDateTime.diffSeconds.call(fromTimestamp, toTimestamp) == 54874983, testDateTime.timestampToDateTime.call(fromTimestamp) + " to " + testDateTime.timestampToDateTime.call(toTimestamp) + " has 54,874,983 seconds diff")) {
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if ("$MODE" == "full") {
  console.log("RESULT: ---------- Test timestampToDateTime.call(...) and timestampFromDateTime.call(...) against JavaScript Date ----------");
  var now = new Date()/1000;

  var fromDate = 0;
  // Year 2345
  var toDate = new Date()/1000 + 328 * 365 * 24 * 60 * 60;
  // 9 weeks
  // var step = 9 * 7 * 24 * 60 * 60;
  // 1 year
  var step = 365 * 24 * 60 * 60;

  var j = 0;
  for (var i = fromDate; i <= toDate; i = parseInt(i) + step) {
    j = parseInt(j * 999991) + 48611;
    if (j > 365 * 24 * 60 * 60) {
      j = j - 365 * 24 * 60 * 60;
    }
    i = parseInt(i) + j % 999991;
    var fromTimestamp = testDateTime.timestampToDateTime.call(i);
    var toTimestamp = testDateTime.timestampFromDateTime.call(fromTimestamp[0], fromTimestamp[1], fromTimestamp[2], fromTimestamp[3], fromTimestamp[4], fromTimestamp[5]);
    var jsDate = new Date(i * 1000);
    console.log("RESULT: timestampToDateTime.call(" + i + ")=" + JSON.stringify(fromTimestamp));
    console.log("RESULT: timestampFromDateTime.call(" + JSON.stringify(fromTimestamp) + ")=" + toTimestamp);
    console.log("RESULT: jsDate(" + i + ")=" + jsDate.getUTCFullYear() + "/" + (parseInt(jsDate.getUTCMonth()) + 1) + "/" + jsDate.getUTCDate() + " " +
      jsDate.getUTCHours() + ":" + jsDate.getUTCMinutes() + ":" + jsDate.getUTCSeconds());

    if (jsDate.getUTCFullYear() == fromTimestamp[0] && parseInt(jsDate.getUTCMonth() + 1) == fromTimestamp[1] && jsDate.getUTCDate() == fromTimestamp[2] &&
      jsDate.getUTCHours() == fromTimestamp[3] && jsDate.getUTCMinutes() == fromTimestamp[4] && jsDate.getUTCSeconds() == fromTimestamp[5]) {
      console.log("RESULT: PASS jsDate matches");
    } else {
      console.log("RESULT: FAIL jsDate does not match");
      failureDetected = true;
    }
    if (i == toTimestamp) {
      console.log("RESULT: PASS timestampToDateTime.call(" + i + ") => timestampFromDateTime.call(...) matches");
    } else {
      console.log("RESULT: FAIL timestampToDateTime.call(" + i + ") => timestampFromDateTime.call(...) does not match");
      failureDetected = true;
    }
    console.log("RESULT: ");
  }
}

if (!failureDetected) {
  console.log("RESULT: ---------- PASS - no failures detected ----------");
} else {
  console.log("RESULT: ---------- FAIL - some failures detected ----------");
}


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
