#!/usr/bin/env bash

MongoHost=10.10.100.201
MongoPort=27017

logFile="/tmp/grepblockUsersInputs.log"

# Log User INPUTS in search bar:
echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` User INPUT: $1" >> $logFile

# Count symbols in user INPUT
checkUserInput="$(echo "$1" | wc -c)"
checkUserInputforValidation=$(echo "$1" | egrep '`|~|@|#|%|\^|&|\*|\(|\)|_|\+|=|-|\||\[|\]|{|}|;|:|"|<|>|\?|,|\.' || echo "AllGood")

# Divide user input & lua base64 path
path2="$2"
path1="/usr/share/nginx/grepblockcom"

# Merge user INPUT and lua base64 path
file="${path1}${path2}"

if [[ "${checkUserInputforValidation}" != "AllGood" ]]; then
        echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` FATAL ERROR - invalid characters: $1" >> $logFile
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
database=( 'dash' 'polis' 'adeptio' 'pivx' 'bitcoin' 'snowgem' 'zcoin' 'syscoin' 'litecoin' 'bitcoin-cash' 'ravencoin' 'horizen' 'solaris' 'zcash' 'decred' 'bitcoin-gold')

function checkAssetNameAndTicker() {
        case $i in
                'dash')
                        assetName="Dash"
                        assetTicker="DASH"
                        ;;
                'polis')
                        assetName="Polis"
                        assetTicker="POLIS"
                        ;;
                'adeptio')
                        assetName="Adeptio"
                        assetTicker="ADE"
                        ;;
                'pivx')
                        assetName="Pivx"
                        assetTicker="PIVX"
                        ;;
                'bitcoin')
                        assetName="Bitcoin"
                        assetTicker="BTC"
                        ;;
                'snowgem')
                        assetName="Snowgem"
                        assetTicker="XSG"
                        ;;
                'zcoin')
                        assetName="Zcoin"
                        assetTicker="XZC"
                        ;;
                'syscoin')
                        assetName="Syscoin"
                        assetTicker="SYS"
                        ;;
                'litecoin')
                        assetName="Litecoin"
                        assetTicker="LTC"
                        ;;
                'bitcoin-cash')
                        assetName="BitcoinCash"
                        assetTicker="BCH"
                        ;;
                'ravencoin')
                        assetName="Ravencoin"
                        assetTicker="RVN"
                        ;;
                'horizen')
                        assetName="Horizen"
                        assetTicker="ZEN"
                        ;;
                'solaris')
                        assetName="Solaris"
                        assetTicker="XLR"
                        ;;
                'zcash')
                        assetName="Zcash"
                        assetTicker="ZEC"
                        ;;
                'decred')
                        assetName="Decred"
                        assetTicker="DCR"
                        ;;
                'bitcoin-gold')
                        assetName="BitcoinGold"
                        assetTicker="BTG"
                        ;;
                *)
                        echo "Error no assetName or Ticker set"
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
        chmod 777 $file
}


if [[ "$checkUserInput" = 65 ]]; then
        startProcessingTime

                for i in "${database[@]}"
                do
                        checkAssetNameAndTicker
                        foundTX="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"tx\" : \"$1\"}, {_id:0, nonce:0, zADEsupply:0})" --quiet $i)"
                        foundBlockHash="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"hash\" : \"$1\"}, {_id:0, nonce:0, zADEsupply:0})" --quiet $i)"

                        if [[ $(echo $foundTX) ]]; then

                                echo "$foundTX" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file


                        elif [[ $(echo $foundBlockHash) ]]; then

                                echo "$foundBlockHash" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file

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
                        foundBlockNumber="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"block\" : $1}, {_id:0, nonce:0, zADEsupply:0})" --quiet $i)"

                        if [[ $(echo $foundBlockNumber) ]]; then

                                echo "$foundBlockNumber" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                                echo "$assetName & $assetTicker" >> /tmp/check.txt
                        else
                                echo "No Files Found in $(echo $i)" > /dev/null

                        fi
                done

        sed -i "s@{@,{@" $file
        stopProcessingTime
        runtime=$((end-start))
        reformatToJSON

else
        echo "{\"WARNING\" : \"No data found among all ${#database[@]} blockchains. You can enter: block hash, number or transaction hash (aka txid). Please take a note that we are not tracking **wallet addresses**\"}" > $file
fi
