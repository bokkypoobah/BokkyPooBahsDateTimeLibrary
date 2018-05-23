#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

DATETIMELIBSOL=`grep ^DATETIMELIBSOL= settings.txt | sed "s/^.*=//"`
DATETIMELIBJS=`grep ^DATETIMELIBJS= settings.txt | sed "s/^.*=//"`
TESTDATETIMESOL=`grep ^TESTDATETIMESOL= settings.txt | sed "s/^.*=//"`
TESTDATETIMEJS=`grep ^TESTDATETIMEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

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

solc_0.4.24 --version | tee -a $TEST1OUTPUT

echo "var dateTimeLibOutput=`solc_0.4.24 --optimize --pretty-json --combined-json abi,bin,interface $DATETIMELIBSOL`;" > $DATETIMELIBJS
echo "var testDateTimeOutput=`solc_0.4.24 --optimize --pretty-json --combined-json abi,bin,interface $TESTDATETIMESOL`;" > $TESTDATETIMEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$DATETIMELIBJS");
loadScript("$TESTDATETIMEJS");
loadScript("functions.js");

var dateTimeLibAbi = JSON.parse(dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].abi);
var dateTimeLibBin = "0x" + dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].bin;
var testDateTimeAbi = JSON.parse(testDateTimeOutput.contracts["$TESTDATETIMESOL:TestDateTime"].abi);
var testDateTimeBin = "0x" + testDateTimeOutput.contracts["$TESTDATETIMESOL:TestDateTime"].bin;

// console.log("DATA: dateTimeLibAbi=" + JSON.stringify(dateTimeLibAbi));
// console.log("DATA: dateTimeLibBin=" + JSON.stringify(dateTimeLibBin));
// console.log("DATA: testDateTimeAbi=" + JSON.stringify(testDateTimeAbi));
// console.log("DATA: testDateTimeBin=" + JSON.stringify(testDateTimeBin));


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


console.log("RESULT: ---------- Test diff{Days|Months|Years} ----------");
var fromTimestamp = testDateTime.timestampFromDateTime(2017, 10, 21, 1, 2, 3);
var toTimestamp = testDateTime.timestampFromDateTime(2019, 7, 18, 4, 5, 6);

var diffDays = testDateTime.diffDays(fromTimestamp, toTimestamp);
console.log("RESULT: diffDays(" + testDateTime.timestampToDateTime(fromTimestamp) + ", " +
  testDateTime.timestampToDateTime(toTimestamp) + ") = " + diffDays);
if (diffDays == 635) {
  console.log("RESULT: PASS diffDays");
} else {
  console.log("RESULT: FAIL diffDays");
}
console.log("RESULT: ");

var diffMonths = testDateTime.diffMonths(fromTimestamp, toTimestamp);
console.log("RESULT: diffMonths(" + testDateTime.timestampToDateTime(fromTimestamp) + ", " +
  testDateTime.timestampToDateTime(toTimestamp) + ") = " + diffMonths);
if (diffMonths == 21) {
  console.log("RESULT: PASS diffMonths");
} else {
  console.log("RESULT: FAIL diffMonths");
}
console.log("RESULT: ");

var diffYears = testDateTime.diffYears(fromTimestamp, toTimestamp);
console.log("RESULT: diffYears(" + testDateTime.timestampToDateTime(fromTimestamp) + ", " +
  testDateTime.timestampToDateTime(toTimestamp) + ") = " + diffYears);
if (diffYears == 2) {
  console.log("RESULT: PASS diffYears");
} else {
  console.log("RESULT: FAIL diffYears");
}
console.log("RESULT: ");


var runFullTest = true;
if (runFullTest) {
console.log("RESULT: ---------- Test timestampToDateTime(...) and timestampFromDateTime(...) against JavaScript Date ----------");
var now = new Date()/1000;

var fromDate = 0;
// Year 2345
var toDate = new Date()/1000 + 328 * 365 * 24 * 60 * 60;
// 9 weeks
// var step = 9 * 7 * 24 * 60 * 60;
// 1 year
var step = 365 * 24 * 60 * 60;

var j = 0;
var failureDetected = false;
for (var i = fromDate; i <= toDate; i = parseInt(i) + step) {
  j = parseInt(j * 999991) + 48611;
  if (j > 365 * 24 * 60 * 60) {
    j = j - 365 * 24 * 60 * 60;
  }
  i = parseInt(i) + j % 999991;
  var fromTimestamp = testDateTime.timestampToDateTime(i);
  var toTimestamp = testDateTime.timestampFromDateTime(fromTimestamp[0], fromTimestamp[1], fromTimestamp[2], fromTimestamp[3], fromTimestamp[4], fromTimestamp[5]);
  var jsDate = new Date(i * 1000);
  console.log("RESULT: timestampToDateTime(" + i + ")=" + JSON.stringify(fromTimestamp));
  console.log("RESULT: timestampFromDateTime(" + JSON.stringify(fromTimestamp) + ")=" + toTimestamp);
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
    console.log("RESULT: PASS timestampToDateTime(" + i + ") => timestampFromDateTime(...) matches");
  } else {
    console.log("RESULT: FAIL timestampToDateTime(" + i + ") => timestampFromDateTime(...) does not match");
    failureDetected = true;
  }
  console.log("RESULT: ");
}

if (!failureDetected) {
  console.log("RESULT: ---------- PASS - no failures detected ----------");
} else {
  console.log("RESULT: ---------- FAIL - some failures detected ----------");
}
}


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS