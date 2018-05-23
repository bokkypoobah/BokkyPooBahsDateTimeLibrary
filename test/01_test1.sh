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
var dateTimeLibContract = dateTimeLibContract.new({from: contractOwnerAccount, data: dateTimeLibBin, gas: 6000000, gasPrice: defaultGasPrice},
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

exit;


// -----------------------------------------------------------------------------
var deployProposalsLibMessage = "Deploy Proposals Library";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployProposalsLibMessage + " -----");
var proposalsLibContract = web3.eth.contract(proposalsLibAbi);
// console.log(JSON.stringify(proposalsLibContract));
var proposalsLibTx = null;
var proposalsLibAddress = null;
var currentBlock = eth.blockNumber;
var proposalsLibContract = proposalsLibContract.new({from: contractOwnerAccount, data: proposalsLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        proposalsLibTx = contract.transactionHash;
      } else {
        proposalsLibAddress = contract.address;
        addAccount(proposalsLibAddress, "Proposals Library");
        console.log("DATA: proposalsLibAddress=" + proposalsLibAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(proposalsLibTx, deployProposalsLibMessage);
printTxData("proposalsLibTx", proposalsLibTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployClubFactoryMessage = "Deploy ClubFactory";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployClubFactoryMessage + " -----");
console.log("RESULT: clubFactoryBin='" + clubFactoryBin + "'");
var newClubFactoryBin = clubFactoryBin.replace(/__ClubEthFactory\.sol\:Members____________/g, membersLibAddress.substring(2, 42)).replace(/__ClubEthFactory\.sol\:Proposals__________/g, proposalsLibAddress.substring(2, 42));
console.log("RESULT: newClubFactoryBin='" + newClubFactoryBin + "'");
var clubFactoryContract = web3.eth.contract(clubFactoryAbi);
// console.log(JSON.stringify(clubFactoryAbi));
// console.log(newClubFactoryBin);
var clubFactoryTx = null;
var clubFactoryAddress = null;
var clubFactory = clubFactoryContract.new({from: contractOwnerAccount, data: newClubFactoryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        clubFactoryTx = contract.transactionHash;
      } else {
        clubFactoryAddress = contract.address;
        addAccount(clubFactoryAddress, "ClubFactory");
        addClubFactoryContractAddressAndAbi(clubFactoryAddress, clubFactoryAbi);
        console.log("DATA: clubFactoryAddress=" + clubFactoryAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(clubFactoryTx, deployClubFactoryMessage);
printTxData("clubFactoryTx", clubFactoryTx);
printClubFactoryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployClubMessage = "Deploy Club Contract";
var clubName = "Babysitters Club";
var tokenSymbol = "SITS";
var tokenName = "Sit Minutes";
var tokenDecimal = 18;
var memberName = "Alice";
var tokensForNewMembers = new BigNumber(200 * 60).shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployClubMessage + " -----");
var clubContract = web3.eth.contract(clubAbi);
// console.log(JSON.stringify(clubContract));
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var deployClubTx = clubFactory.deployClubEthContract(clubName, tokenSymbol, tokenName, tokenDecimal, memberName, tokensForNewMembers, {from: aliceAccount, gas: 4000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var results = getClubAndTokenListing();
var clubs = results[0];
var tokens = results[1];
console.log("RESULT: clubs=#" + clubs.length + " " + JSON.stringify(clubs));
console.log("RESULT: tokens=#" + tokens.length + " " + JSON.stringify(tokens));
// Can check, but the rest will not work anyway - if (bttsTokens.length == 1)
var clubAddress = clubs[0];
var tokenAddress = tokens[0];
var club = web3.eth.contract(clubAbi).at(clubAddress);
console.log("DATA: clubAddress=" + clubAddress);
var token = web3.eth.contract(tokenAbi).at(tokenAddress);
console.log("DATA: tokenAddress=" + tokenAddress);
addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
addAccount(clubAddress, "Club '" + club.name() + "'");
addClubContractAddressAndAbi(clubAddress, clubAbi);
addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
printBalances();
failIfTxStatusError(deployClubTx, deployClubMessage);
printTxData("deployClubTx", deployClubTx);
printClubFactoryContractDetails();
printTokenContractDetails();
printClubContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setMemberNameMessage = "Set Member Name";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + setMemberNameMessage + " -----");
var setMemberNameTx = club.setMemberName("Alice in Blockchains", {from: aliceAccount, gas: 4000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
failIfTxStatusError(setMemberNameTx, setMemberNameMessage);
printTxData("setMemberNameTx", setMemberNameTx);
printClubContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addMemberProposal1_Message = "Add Member Proposal #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + addMemberProposal1_Message + " -----");
var addMemberProposal1_1Tx = club.proposeAddMember("Bob", bobAccount, {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addMemberProposal1_1Tx, addMemberProposal1_Message + " - Alice addMemberProposal(ac3, 'Bob')");
printTxData("addMemberProposal1_1Tx", addMemberProposal1_1Tx);
printClubContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addMemberProposal2_Message = "Add Member Proposal #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + addMemberProposal2_Message + " -----");
var addMemberProposal2_1Tx = club.proposeAddMember("Carol", carolAccount, {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var addMemberProposal2_2Tx = club.voteNo(1, {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var addMemberProposal2_3Tx = club.voteYes(1, {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var addMemberProposal2_4Tx = club.voteYes(1, {from: bobAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addMemberProposal2_1Tx, addMemberProposal2_Message + " - Alice addMemberProposal(ac4, 'Carol')");
failIfTxStatusError(addMemberProposal2_2Tx, addMemberProposal2_Message + " - Alice voteNo(1)");
failIfTxStatusError(addMemberProposal2_3Tx, addMemberProposal2_Message + " - Alice voteYes(1)");
failIfTxStatusError(addMemberProposal2_4Tx, addMemberProposal2_Message + " - Bob voteYes(1)");
printTxData("addMemberProposal2_1Tx", addMemberProposal2_1Tx);
printTxData("addMemberProposal2_2Tx", addMemberProposal2_2Tx);
printTxData("addMemberProposal2_3Tx", addMemberProposal2_3Tx);
printTxData("addMemberProposal2_4Tx", addMemberProposal2_4Tx);
printClubContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var removeMemberProposal1_Message = "Remove Member Proposal #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + removeMemberProposal1_Message + " -----");
var removeMemberProposal1_1Tx = club.proposeRemoveMember("Remove Bob", bobAccount, {from: carolAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var removeMemberProposal1_2Tx = club.voteYes(2, {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(removeMemberProposal1_1Tx, removeMemberProposal1_Message + " - Carol removeMemberProposal(ac3, 'Bob')");
failIfTxStatusError(removeMemberProposal1_2Tx, removeMemberProposal1_Message + " - Alice voteYes(2)");
printTxData("removeMemberProposal1_1Tx", removeMemberProposal1_1Tx);
printTxData("removeMemberProposal1_2Tx", removeMemberProposal1_2Tx);
printClubContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintTokensProposal1_Message = "Mint Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + mintTokensProposal1_Message + " -----");
var mintTokensProposal1_1Tx = club.proposeMintTokens("Mint tokens Alice", aliceAccount, new BigNumber("100000").shift(18), {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var mintTokensProposal1_2Tx = club.voteYes(3, {from: bobAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var mintTokensProposal1_3Tx = club.voteYes(3, {from: carolAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(mintTokensProposal1_1Tx, mintTokensProposal1_Message + " - Alice proposeMintTokens(Alice, 100000 tokens)");
passIfTxStatusError(mintTokensProposal1_2Tx, mintTokensProposal1_Message + " - Bob voteYes(3) - Expecting failure as not a member");
failIfTxStatusError(mintTokensProposal1_3Tx, mintTokensProposal1_Message + " - Carol voteYes(3)");
printTxData("mintTokensProposal1_1Tx", mintTokensProposal1_1Tx);
printTxData("mintTokensProposal1_2Tx", mintTokensProposal1_2Tx);
printTxData("mintTokensProposal1_3Tx", mintTokensProposal1_3Tx);
printClubContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var burnTokensProposal1_Message = "Burn Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + burnTokensProposal1_Message + " -----");
var burnTokensProposal1_1Tx = club.proposeBurnTokens("Burn tokens Alice", aliceAccount, new BigNumber("50000").shift(18), {from: aliceAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var burnTokensProposal1_2Tx = club.voteYes(4, {from: bobAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var burnTokensProposal1_3Tx = club.voteYes(4, {from: carolAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(burnTokensProposal1_1Tx, burnTokensProposal1_Message + " - Alice proposeBurnTokens(Alice, 100000 tokens)");
passIfTxStatusError(burnTokensProposal1_2Tx, burnTokensProposal1_Message + " - Bob voteYes(4) - Expecting failure as not a member");
failIfTxStatusError(burnTokensProposal1_3Tx, burnTokensProposal1_Message + " - Carol voteYes(4)");
printTxData("burnTokensProposal1_1Tx", burnTokensProposal1_1Tx);
printTxData("burnTokensProposal1_2Tx", burnTokensProposal1_2Tx);
printTxData("burnTokensProposal1_3Tx", burnTokensProposal1_3Tx);
printClubContractDetails();
printTokenContractDetails();
console.log("RESULT: ");



exit;



// -----------------------------------------------------------------------------
var deployLibDAOMessage = "Deploy DAO Library";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployLibDAOMessage + " -----");
var membersLibContract = web3.eth.contract(membersLibAbi);
// console.log(JSON.stringify(membersLibContract));
var membersLibTx = null;
var membersLibAddress = null;
var membersLibBTTS = membersLibContract.new({from: contractOwnerAccount, data: membersLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        membersLibTx = contract.transactionHash;
      } else {
        membersLibAddress = contract.address;
        addAccount(membersLibAddress, "DAO Library - Members");
        console.log("DATA: membersLibAddress=" + membersLibAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(membersLibTx, deployLibDAOMessage);
printTxData("membersLibTx", membersLibTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployDAOMessage = "Deploy DAO Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployDAOMessage + " -----");
var newDAOBin = daoBin.replace(/__DecentralisedFutureFundDAO\.sol\:Membe__/g, membersLibAddress.substring(2, 42));
var daoContract = web3.eth.contract(daoAbi);
var daoTx = null;
var daoAddress = null;
var dao = daoContract.new({from: contractOwnerAccount, data: newDAOBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        daoTx = contract.transactionHash;
      } else {
        daoAddress = contract.address;
        addAccount(daoAddress, "DFF DAO");
        addDAOContractAddressAndAbi(daoAddress, daoAbi);
        console.log("DATA: daoAddress=" + daoAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(daoTx, deployDAOMessage);
printTxData("daoAddress=" + daoAddress, daoTx);
printDAOContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initSetBTTSToken_Message = "Initialisation - Set BTTS Token";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + initSetBTTSToken_Message + " -----");
var initSetBTTSToken_1Tx = dao.initSetBTTSToken(tokenAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var initSetBTTSToken_2Tx = token.setMinter(daoAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var initSetBTTSToken_3Tx = token.transferOwnershipImmediately(daoAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var initSetBTTSToken_4Tx = eth.sendTransaction({from: contractOwnerAccount, to: daoAddress, value: web3.toWei("100", "ether"), gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(initSetBTTSToken_1Tx, initSetBTTSToken_Message + " - dao.initSetBTTSToken(bttsToken)");
failIfTxStatusError(initSetBTTSToken_2Tx, initSetBTTSToken_Message + " - token.setMinter(dao)");
failIfTxStatusError(initSetBTTSToken_3Tx, initSetBTTSToken_Message + " - token.transferOwnershipImmediately(dao)");
failIfTxStatusError(initSetBTTSToken_4Tx, initSetBTTSToken_Message + " - send 100 ETH to dao");
printTxData("initSetBTTSToken_1Tx", initSetBTTSToken_1Tx);
printTxData("initSetBTTSToken_2Tx", initSetBTTSToken_2Tx);
printTxData("initSetBTTSToken_3Tx", initSetBTTSToken_3Tx);
printTxData("initSetBTTSToken_4Tx", initSetBTTSToken_4Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initAddMembers_Message = "Initialisation - Add Members";
var name1 = "0x" + web3.padLeft(web3.toHex("two").substring(2), 64);
var name2 = "0x" + web3.padLeft(web3.toHex("three").substring(2), 64);
var name3 = "0x" + web3.padLeft(web3.toHex("four").substring(2), 64);
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + initAddMembers_Message + " -----");
var initAddMembers_1Tx = dao.initAddMember(account2, name1, true, {from: contractOwnerAccount, gas: 300000, gasPrice: defaultGasPrice});
var initAddMembers_2Tx = dao.initAddMember(account3, name2, true, {from: contractOwnerAccount, gas: 300000, gasPrice: defaultGasPrice});
var initAddMembers_3Tx = dao.initAddMember(account4, name3, false, {from: contractOwnerAccount, gas: 300000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(initAddMembers_1Tx, initAddMembers_Message + " - dao.initAddMember(account2, 'two', true)");
failIfTxStatusError(initAddMembers_2Tx, initAddMembers_Message + " - dao.initAddMember(account3, 'three', true)");
failIfTxStatusError(initAddMembers_3Tx, initAddMembers_Message + " - dao.initAddMember(account4, 'four', false)");
printTxData("initAddMembers_1Tx", initAddMembers_1Tx);
printTxData("initAddMembers_2Tx", initAddMembers_2Tx);
printTxData("initAddMembers_3Tx", initAddMembers_3Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


if (false) {
// -----------------------------------------------------------------------------
var initRemoveMembers_Message = "Initialisation - Remove Members";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + initRemoveMembers_Message + " -----");
var initRemoveMembers_1Tx = dao.initRemoveMember(account2, {from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
var initRemoveMembers_2Tx = dao.initRemoveMember(account3, {from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
var initRemoveMembers_3Tx = dao.initRemoveMember(account4, {from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(initRemoveMembers_1Tx, initRemoveMembers_Message + " - dao.initRemoveMember(account2)");
failIfTxStatusError(initRemoveMembers_2Tx, initRemoveMembers_Message + " - dao.initRemoveMember(account3)");
failIfTxStatusError(initRemoveMembers_3Tx, initRemoveMembers_Message + " - dao.initRemoveMember(account4)");
printTxData("initRemoveMembers_1Tx", initRemoveMembers_1Tx);
printTxData("initRemoveMembers_2Tx", initRemoveMembers_2Tx);
printTxData("initRemoveMembers_3Tx", initRemoveMembers_3Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var initialisationComplete_Message = "Initialisation - Complete";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + initialisationComplete_Message + " -----");
var initialisationComplete_1Tx = dao.initialisationComplete({from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(initialisationComplete_1Tx, initialisationComplete_Message + " - dao.initialisationComplete()");
printTxData("initialisationComplete_1Tx", initialisationComplete_1Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var etherPaymentProposal_Message = "Ether Payment Proposal";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + etherPaymentProposal_Message + " -----");
var etherPaymentProposal_1Tx = dao.proposeEtherPayment("payment to ac2", account2, new BigNumber("12").shift(18), {from: account2, gas: 300000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(etherPaymentProposal_1Tx, etherPaymentProposal_Message + " - dao.proposeEtherPayment(ac2, 12 ETH)");
printTxData("etherPaymentProposal_1Tx", etherPaymentProposal_1Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var vote1_Message = "Vote - Ether Payment Proposal";
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + vote1_Message + " -----");
var vote1_1Tx = dao.voteYes(0, {from: account3, gas: 300000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(vote1_1Tx, vote1_Message + " - ac3 dao.voteYes(proposal 0)");
printTxData("vote1_1Tx", vote1_1Tx);
printDAOContractDetails();
printTokenContractDetails();
console.log("RESULT: ");



EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS