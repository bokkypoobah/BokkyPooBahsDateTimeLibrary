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
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $SOURCEDIR/$DATETIMELIBSOL .`

# --- Modify parameters ---
# `perl -pi -e "s/START_DATE \= 1525132800.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
# `perl -pi -e "s/endDate \= 1527811200;.*$/endDate \= $END_DATE; \/\/ $END_DATE_S/" $CROWDSALESOL`

DIFFS1=`diff $SOURCEDIR/$DATETIMELIBSOL $DATETIMELIBSOL`
echo "--- Differences $SOURCEDIR/$DATETIMELIBSOL $DATETIMELIBSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.24 --version | tee -a $TEST1OUTPUT

echo "var dateTimeLibOutput=`solc_0.4.24 --optimize --pretty-json --combined-json abi,bin,interface $DATETIMELIBSOL`;" > $DATETIMELIBJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$DATETIMELIBJS");
loadScript("functions.js");

var dateTimeLibAbi = JSON.parse(dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].abi);
var dateTimeLibBin = "0x" + dateTimeLibOutput.contracts["$DATETIMELIBSOL:BokkyPooBahsDateTimeLibrary"].bin;

// console.log("DATA: dateTimeLibAbi=" + JSON.stringify(dateTimeLibAbi));
// console.log("DATA: dateTimeLibBin=" + JSON.stringify(dateTimeLibBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployDateTimeLibbMessage = "Deploy DateTime Library";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployDateTimeLibbMessage + " -----");
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
        console.log("DATA: dateTimeLibAddress=" + dateTimeLibAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(dateTimeLibTx, deployDateTimeLibbMessage);
printTxData("dateTimeLibTx", dateTimeLibTx);
console.log("RESULT: ");


console.log("RESULT: ---------- Test timestampToDateTime(...) and timestampFromDateTime(...) against JavaScript Date ----------");
var now = new Date()/1000;

var fromDate = 0;
var toDate = new Date()/1000 + 19 * 365 * 24 * 60 * 60;
// 9 weeks
// var step = 9 * 7 * 24 * 60 * 60;
// 1 year
var step = 365 * 24 * 60 * 60;

var j = 0;
var failureDetected = false;
for (var i = fromDate; i <= toDate; i = parseInt(i) + step) {
  j = parseInt(j * 73241) + 173;
  if (j > 3000000) {
    j = j - 3000000;
  }
  i = parseInt(i) + j % 72373;
  var fromTimestamp = dateTimeLib.timestampToDateTime(i);
  var toTimestamp = dateTimeLib.timestampFromDateTime(fromTimestamp[0], fromTimestamp[1], fromTimestamp[2], fromTimestamp[3], fromTimestamp[4], fromTimestamp[5]);
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

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS