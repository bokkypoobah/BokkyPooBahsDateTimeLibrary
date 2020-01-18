# Contract - Testing

<br />

<hr />

# Table of contents

* [Requirements](#requirements)
* [Executing The Tests](#executing-the-tests)
* [Notes](#notes)

<br />

<hr />

# Requirements

* The tests works on OS/X. Should work in Linux. May work in Windows with Cygwin
* Geth/v1.9.9-stable-01744997/darwin-amd64/go1.13.5 running with the Byzantium fork switched on
* Solc 0.6.0+commit.26b70077.Darwin.appleclang

<br />

<hr />

# Executing The Tests

* Run `geth` in dev mode

      ./00_runGeth.sh

* Run the test in [01_test1.sh](01_test1.sh)

      ./01_test1.sh

* See  [test1results.txt](test1results.txt) for the results and [test1output.txt](test1output.txt) for the full output.

<br />

<hr />

# Notes

* The tests were conducted using bash shell scripts running Geth/v1.9.9-stable-01744997/darwin-amd64/go1.13.5 JavaScript commands
* The smart contracts were compiled using Solidity 0.6.0+commit.26b70077.Darwin.appleclang
* The test script can be found in [01_test1.sh](01_test1.sh)
* The test results can be found in [test1results.txt](test1results.txt) with details in [test1output.txt](test1output.txt)
* The test can be run on OS/X, should run on Linux and may run on Windows with Cygwin
* The [genesis.json](genesis.json) allocates ethers to the test accounts, and specifies a high block gas limit to accommodate many transactions in the same block
* The [00_runGeth.sh](00_runGeth.sh) scripts starts `geth` with the parameter `--targetgaslimit 994712388` to keep the high block gas limit
* The reasons for using the test environment as listed above, instead of truffles/testrpc are:
  * The test are conducted using the actual blockchain client software as is running on Mainnet and not just a mock environment like testrpc
  * It is easy to change parameters like dates, addresses or blocknumbers using the Unix search/replace tools
  * There have been issues in the part with version incompatibility between testrpc and solidity, i.e., version mismatches
  * The intermediate and key results are all saved to later viewing
