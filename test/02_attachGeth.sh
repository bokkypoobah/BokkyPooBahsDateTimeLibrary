#!/bin/sh


echo "Execute the following command to load the latest deployed contracts";
echo ""
echo "loadScript(\"deploymentData.js\");"
echo ""

geth attach ipc:./testchain/geth.ipc
