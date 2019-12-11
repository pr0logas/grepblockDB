#!/usr/bin/env bash

MongoHost=10.10.100.201
MongoPort=27017

logFile="/tmp/grepblockUsersInputs.log"

# Log User INPUTS in search bar:
echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` User INPUT: $1 IP: $3" >> $logFile

# Count symbols in user INPUT
checkUserInput="$(echo "$1" | wc -c)"
checkUserInputforValidation=$(echo "$1" | egrep '`|~|@|#|%|\^|&|\*|\(|\)|_|\+|=|-|\||\[|\]|{|}|;|:|"|<|>|\?|,|\.' || echo "AllGood")

# Divide user input & lua base64 path
path2="$2"
path1="/usr/share/nginx/grepblockcom"

# Merge user INPUT and lua base64 path
file="${path1}${path2}"

if [[ "${checkUserInputforValidation}" != "AllGood" ]]; then
        echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` FATAL ERROR - invalid characters: $1 IP: $3" >> $logFile
        exit 1

elif [[ $(echo $path2) ]]; then
        echo "ALL good let's continue" > /dev/null
else
        echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` FATAL ERROR - there are no base64 path from NGINX LUA module?" >> $logFile
        exit 1
fi

> "$file"

### Preparing to search content in MongoDB ###

# Assets to loop
database=('horizen' 'dash' 'polis' 'adeptio' 'pivx' 'bitcoin' 'snowgem' 'zcoin' 'syscoin' 'litecoin' 'ravencoin' 'decred' 'solaris' 'bitcoin-cash' 'bitcoin-gold' 'digibyte' 'reddcoin' 'monacoin' 'zcash' 'safecapital' 'safeinsure' 'biblepay')

function checkAssetNameAndTicker() {
         case $i in
                'dash')
                        assetName="Dash"
                        assetTicker="DASH"
                        assetExplorerLinkBlocks='https://live.blockcypher.com/dash/block/'
                        assetExplorerLinkBlockHashs='https://live.blockcypher.com/dash/block/'
                        assetExplorerLinkTransactions='https://live.blockcypher.com/dash/tx/'
                        assetExplorerLinkWallets='https://live.blockcypher.com/dash/address/'
                        ;;
                'polis')
                        assetName="Polis"
                        assetTicker="POLIS"
                        assetExplorerLinkBlocks='https://blockbook.polispay.org/block/'
                        assetExplorerLinkBlockHashes='https://blockbook.polispay.org/block/'
                        assetExplorerLinkTransactions='https://blockbook.polispay.org/tx/'
                        assetExplorerLinkWallets='https://blockbook.polispay.org/address/'
                        ;;
                'adeptio')
                        assetName="Adeptio"
                        assetTicker="ADE"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/ade/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/ade/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/ade/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/ade/address.dws?'
                        ;;
                'pivx')
                        assetName="Pivx"
                        assetTicker="PIVX"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/pivx/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/pivx/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/pivx/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/pivx/address.dws?'
                        ;;
                'bitcoin')
                        assetName="Bitcoin"
                        assetTicker="BTC"
                        assetExplorerLinkBlocks='https://live.blockcypher.com/btc/block/'
                        assetExplorerLinkBlockHashes='https://live.blockcypher.com/btc/block/'
                        assetExplorerLinkTransactions='https://live.blockcypher.com/btc/tx/'
                        assetExplorerLinkWallets='https://live.blockcypher.com/btc/address/'
                        ;;
                'snowgem')
                        assetName="Snowgem"
                        assetTicker="XSG"
                        assetExplorerLinkBlocks='https://explorer.snowgem.org/block/'
                        assetExplorerLinkBlockHashes='https://explorer.snowgem.org/block/'
                        assetExplorerLinkTransactions='https://explorer.snowgem.org/tx/'
                        assetExplorerLinkWallets='https://explorer.snowgem.org/address/'
                        ;;
                'zcoin')
                        assetName="Zcoin"
                        assetTicker="XZC"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/xzc/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/xzc/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/xzc/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/xzc/address.dws?'
                        ;;
                'syscoin')
                        assetName="Syscoin"
                        assetTicker="SYS"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/sys/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/sys/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/sys/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/sys/address.dws?'
                        ;;
                'litecoin')
                        assetName="Litecoin"
                        assetTicker="LTC"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/ltc/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/ltc/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/ltc/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/ltc/address.dws?'
                        ;;
                'bitcoin-cash')
                        assetName="BitcoinCash"
                        assetTicker="BCH"
                        assetExplorerLinkBlocks='https://blockchair.com/bitcoin-cash/block/'
                        assetExplorerLinkBlockHashes='https://blockchair.com/bitcoin-cash/block/'
                        assetExplorerLinkTransactions='https://blockchair.com/bitcoin-cash/transaction/'
                        assetExplorerLinkWallets='https://blockchair.com/bitcoin-cash/address/'
                        ;;
                'ravencoin')
                        assetName="Ravencoin"
                        assetTicker="RVN"
                        assetExplorerLinkBlocks='https://ravencoin.network/block/'
                        assetExplorerLinkBlockHashes='https://ravencoin.network/block/'
                        assetExplorerLinkTransactions='https://ravencoin.network/tx/'
                        assetExplorerLinkWallets='https://ravencoin.network/address/'
                        ;;
                'horizen')
                        assetName="Horizen"
                        assetTicker="ZEN"
                        assetExplorerLinkBlocks='https://explorer.zensystem.io/block/'
                        assetExplorerLinkBlockHashes='https://explorer.zensystem.io/block/'
                        assetExplorerLinkTransactions='https://explorer.zensystem.io/tx/'
                        assetExplorerLinkWallets='https://explorer.zensystem.io/address/'             
                        ;;
                'solaris')
                        assetName="Solaris"
                        assetTicker="XLR"
                        assetExplorerLinkBlocks='https://explorer.solarisplatform.com/Search?Query='
                        assetExplorerLinkBlockHashes='https://explorer.solarisplatform.com/Block/'
                        assetExplorerLinkTransactions='https://explorer.solarisplatform.com/Transaction/'
                        assetExplorerLinkWallets='https://explorer.solarisplatform.com/Address/'  
                        ;;
                'zcash')
                        assetName="Zcash"
                        assetTicker="ZEC"
                        assetExplorerLinkBlocks='https://explorer.zcha.in/blocks/'
                        assetExplorerLinkBlockHashes='https://explorer.zcha.in/blocks/'
                        assetExplorerLinkTransactions='https://explorer.zcha.in/transactions/'
                        assetExplorerLinkWallets='https://explorer.zcha.in/accounts/' 
                        ;;
                'decred')
                        assetName="Decred"
                        assetTicker="DCR"
                        assetExplorerLinkBlocks='https://explorer.dcrdata.org/block/'
                        assetExplorerLinkBlockHashes='https://explorer.dcrdata.org/block/'
                        assetExplorerLinkTransactions='https://explorer.dcrdata.org/tx/'
                        assetExplorerLinkWallets='https://explorer.dcrdata.org/address/' 
                        ;;
                'bitcoin-gold')
                        assetName="BitcoinGold"
                        assetTicker="BTG"
                        assetExplorerLinkBlocks='https://btg.tokenview.com/en/block/'
                        assetExplorerLinkBlockHashes='https://btg.tokenview.com/en/block/'
                        assetExplorerLinkTransactions='https://btg.tokenview.com/en/tx/'
                        assetExplorerLinkWallets='https://btg.tokenview.com/en/address/' 
                        ;;
                'digibyte')
                        assetName="Digibyte"
                        assetTicker="DGB"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/dgb/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/dgb/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/dgb/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/dgb/address.dws?'
                        ;;
                'reddcoin')
                        assetName="Reddcoin"
                        assetTicker="RDD"
			assetExplorerLinkBlocks='https://live.reddcoin.com/block/'
                    	assetExplorerLinkBlockHashes='https://live.reddcoin.com/block/'
                        assetExplorerLinkTransactions='https://live.reddcoin.com/tx/'
                        assetExplorerLinkWallets='https://live.reddcoin.com/address/'
                        ;;
                'monacoin')
                        assetName="Monacoin"
                        assetTicker="MONA"
                        assetExplorerLinkBlocks='https://mona.chainsight.info/block/'
                        assetExplorerLinkBlockHashes='https://mona.chainsight.info/block/'
                        assetExplorerLinkTransactions='https://mona.chainsight.info/tx/'
                        assetExplorerLinkWallets='https://mona.chainsight.info/address/'
                        ;;
                'zcash')
                        assetName="Zcash"
                        assetTicker="ZEC"
                        assetExplorerLinkBlocks='https://zcash.blockexplorer.com/block/'
                        assetExplorerLinkBlockHashes='https://zcash.blockexplorer.com/block/'
                        assetExplorerLinkTransactions='https://zcash.blockexplorer.com/tx/'
                        assetExplorerLinkWallets='https://zcash.blockexplorer.com/address/'
                        ;;
                'safecapital')
                        assetName="Safecapital"
                        assetTicker="SCAP"
                        assetExplorerLinkBlocks='http://explorer.safecapital.io/block/'
                        assetExplorerLinkBlockHashes='http://explorer.safecapital.io/block/'
                        assetExplorerLinkTransactions='http://explorer.safecapital.io/tx/'
                        assetExplorerLinkWallets='http://explorer.safecapital.io/address/'
                        ;;
                'safeinsure')
                        assetName="Safeinsure"
                        assetTicker="SINS"
                        assetExplorerLinkBlocks='http://explorer.safeinsure.io/block/'
                        assetExplorerLinkBlockHashes='http://explorer.safeinsure.io/block/'
                        assetExplorerLinkTransactions='http://explorer.safeinsure.io/tx/'
                        assetExplorerLinkWallets='http://explorer.safeinsure.io/address/'
			;;
                'biblepay')
                        assetName="Biblepay"
                        assetTicker="BBP"
                        assetExplorerLinkBlocks='https://chainz.cryptoid.info/bbp/block.dws?'
                        assetExplorerLinkBlockHashes='https://chainz.cryptoid.info/bbp/block.dws?'
                        assetExplorerLinkTransactions='https://chainz.cryptoid.info/bbp/tx.dws?'
                        assetExplorerLinkWallets='https://chainz.cryptoid.info/bbp/address.dws?'
                        ;;
                *)
                        echo "Error no assetName or assetTicker set"
                        exit 1
                        ;;
        esac
}

function startProcessingTime() {
        start=$(($(date +%s%N)/1000000))
}

function stopProcessingTime() {
        end=$(($(date +%s%N)/1000000))
}

function reformatToJSON() {

        sed -i "1 i\ \"ProcessingTook\": \"${runtime} ms among ${#database[@]} blockchains\"\," $file
        sed -i "2 i\ \"SearchData\" :" $file
        sed -i "3 i\ [" $file
        sed -i '1 i\{' $file
        sed -i "\$a\]" $file
        sed -i "\$a\}" $file
        sed -i '5s/,{/{/' $file
}


if [[ "$checkUserInput" = 65 ]]; then
        startProcessingTime

                for i in "${database[@]}"
                do
                        checkAssetNameAndTicker
                        foundTX="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"tx\" : \"$1\"}, {_id:0, nonce:0, zADEsupply:0})" --quiet $i)"
                        foundBlockHash="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"hash\" : \"$1\"}, {_id:0, nonce:0})" --quiet $i)"

                        if [[ $(echo $foundTX) ]]; then

                                echo "$foundTX" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlocks\": \"$assetExplorerLinkBlocks\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlockHashes\": \"$assetExplorerLinkBlockHashes\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkTransactions\": \"$assetExplorerLinkTransactions\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkWallets\": \"$assetExplorerLinkWallets\"\,@" $file
                                sed -i "1s@{@{\"assetName\": \"$assetName\"\,@" $file
                                sed -i "1s@{@{\"assetTicker\": \"$assetTicker\"\,@" $file


                        elif [[ $(echo $foundBlockHash) ]]; then

                                echo "$foundBlockHash" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlocks\": \"$assetExplorerLinkBlocks\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlockHashes\": \"$assetExplorerLinkBlockHashes\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkTransactions\": \"$assetExplorerLinkTransactions\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkWallets\": \"$assetExplorerLinkWallets\"\,@" $file
                                sed -i "1s@{@{\"assetName\": \"$assetName\"\,@" $file
                                sed -i "1s@{@{\"assetTicker\": \"$assetTicker\"\,@" $file

                        else

                                echo "No Files Found in $(echo $i)" > /dev/null

                        fi

                done

        sed -i "s@{@,{@" $file
        stopProcessingTime
        runtime=$((end-start))
        reformatToJSON

elif  [[ "$checkUserInput" -le 10 ]] && [[ "$checkUserInput" =~ ^[0-9]+$ ]]; then
        startProcessingTime
                for i in "${database[@]}"
                do
                        checkAssetNameAndTicker
                        foundBlockNumber="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"block\" : $1}, {_id:0, nonce:0})" --quiet $i)"

                        if [[ $(echo $foundBlockNumber) ]]; then

                                echo "$foundBlockNumber" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlocks\": \"$assetExplorerLinkBlocks\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlockHashes\": \"$assetExplorerLinkBlockHashes\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkTransactions\": \"$assetExplorerLinkTransactions\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkWallets\": \"$assetExplorerLinkWallets\"\,@" $file
                                sed -i "1s@{@{\"assetName\": \"$assetName\"\,@" $file
                                sed -i "1s@{@{\"assetTicker\": \"$assetTicker\"\,@" $file
                        else
                                echo "No Files Found in $(echo $i)" > /dev/null

                        fi
                done

        sed -i "s@{@,{@" $file
        stopProcessingTime
        runtime=$((end-start))
        reformatToJSON

elif [[ "$checkUserInput" -ge 26 ]] && [[ "$checkUserInput" -le 50 ]] && [[ "$1" =~ ^[A-Za-z0-9]+$ ]]; then
        startProcessingTime
                for i in "${database[@]}"
                do
                        checkAssetNameAndTicker
                        foundWalletAddr="$(mongo --host $MongoHost --port $MongoPort --eval "db.wallets.find({\"wallet\" : \"$1\"}, {_id:0, nonce:0})" --quiet $i)"

                        if [[ $(echo $foundWalletAddr) ]]; then

                                echo "$foundWalletAddr" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlocks\": \"$assetExplorerLinkBlocks\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkBlockHashes\": \"$assetExplorerLinkBlockHashes\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkTransactions\": \"$assetExplorerLinkTransactions\"\,@" $file
                                sed -i "1s@{@{\"assetExplorerLinkWallets\": \"$assetExplorerLinkWallets\"\,@" $file
                                sed -i "1s@{@{\"assetName\": \"$assetName\"\,@" $file
                                sed -i "1s@{@{\"assetTicker\": \"$assetTicker\"\,@" $file
                        else
                                echo "No Files Found in $(echo $i)" > /dev/null

                        fi
                done

        sed -i "s@{@,{@" $file
        stopProcessingTime
        runtime=$((end-start))
        reformatToJSON

else
        echo "{\"WARNING\" : \"No data found among all ${#database[@]} blockchains. You can enter: block number or hash, transaction hash (aka txid) and wallet address.\"}" > $file
fi
