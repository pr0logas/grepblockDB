#!/usr/bin/env bash

MongoHost=10.10.100.201
MongoPort=27017

logFile="/tmp/grepblockUsersInputs.log"

# Log User INPUTS in search bar:
echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` User INPUT: $1" >> $logFile

# Count symbols in user INPUT
checkUserInput="$(echo "$1" | wc -c)"

# Divide user input & lua base64 path
path2="$2"
path1="/usr/share/nginx/grepblockcom"

# Merge user INPUT and lua base64 path
file="${path1}${path2}"

# Check if lua base64 path arrived?
if [[ $(echo $path2) ]]; then
        echo "ALL good let's continue" > /dev/null
else
        echo "`date +%Y-%m-%d\|%H:%M:%S\|%N` FATAL error - there are no base64 path from NGINX LUA module?" >> $logFile
        exit 1
fi

> "$file"

### Preparing to search content in MongoDB ###

# Assets to loop
database=( 'dash' 'polis' 'adeptio' 'pivx' 'bitcoin' 'snowgem' 'zcoin' 'syscoin' 'litecoin' 'bitcoin-cash' 'ravencoin' 'horizen' 'solaris' 'zcash')

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
                        foundBlockNumber="$(mongo --host $MongoHost --port $MongoPort --eval "db.blocks.find({\"block\" : $1}, {_id:0, nonce:0, zADEsupply:0})" --quiet $i)"

                        if [[ $(echo $foundBlockNumber) ]]; then

                                echo "$foundBlockNumber" | cat - $file | sponge $file
                                sed -i "1s@{@{\"FoundDataIn\": \"$(echo $i)\"\,@" $file
                        else
                                echo "No Files Found in $(echo $i)" > /dev/null

                        fi
                done

        sed -i "s@{@,{@" $file
        stopProcessingTime
        runtime=$((end-start))
        reformatToJSON

else
        echo "{\"FATAL\" : \"No data found among all ${#database[@]} blockchains. You can enter: block hash, number or transaction hash (aka txid). Please take a note that we are not tracking **wallet addresses**\"}" > $file
fi
