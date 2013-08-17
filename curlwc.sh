#! /bin/bash
# ↄ⃝ Murukesh Mohanan
# This scipt will use curl (assuming it's somehwhere in your $PATH) to download
# a file in pieces of 149 MB, or whatever size you specify (in MB). 
# Unfortunately, there's not much support for arguments and switches to the 
# script. The currently fixed order is (with default values):
#  <target URL> [target directory = $PWD] [piece size in MB = 149]
# The intermediate pieces are stored in adirectory named ".tempdir" in the 
# target directory, with the part number (starting from 0) appended to it.
# It so happens that the script will try to resume download using any ".0" part
# in that directory, since my string manipulation isn't that good. Sorry!
# You may modify it as you please, so long as you tell me what you did, so that
# I can make use of any improvements you made. :) Happy downloading!

function INT_cleanup()
{
    kill `jobs -p`    
    exit
}

trap INT_cleanup INT

status=0
temp_dir=".tempdir"

if [ -z $1 ]; then
    echo "Usage: "
    echo "<script name> URL [Target Directory] [piece size in MB]"
    echo "Please specify a URL to download, if you still wanna continue."
    read download_URL
else
    download_URL="$1"
fi

if [ -z $2 ]; then
    working_dir="$PWD"
else
    working_dir="$2"
fi

if [ -z $3 ]; then
    piece_size=$((149*1024*1024))
else
    piece_size=$(($3*1024*1024))
fi

cd $working_dir

file_size=$((`curl $download_URL -s -I -L | grep "200 OK" -A 10 | grep "Content-Length: " | grep '[0-9]*' -o`))
# There's nothing magical about the numbers 16 and 1, they're merely the lengths
# of "Content-Length: " and the "\r" characters at the end of the line
# returned by grep. Didn't make much sense making variables for them.

num_parts=$((file_size / piece_size))
part_size[$num_parts]=$((file_size % piece_size))

if [[ ! -d $temp_dir ]]; then
    mkdir $temp_dir
fi

cd $temp_dir

for i in `seq 0 $((num_parts - 1))`; do
        part_size[$i]=$((piece_size))
done

if ls | grep ".0" -q; then 
    file_name="$(ls *.0)"
    file_name=${file_name%".0"}
else
    curl --remote-name --silent $download_URL --range 0-0 --location
    file_name="$(ls)"
    part_name="`echo $file_name.0`"
    mv $file_name -T "$part_name"
fi

while [ $status -eq 0 ]; do
    loop_iterations=`expr $loop_iterations + 1`
            
    for i in `seq 0 $num_parts`; do
        part_name="`echo $file_name.$i`"
        
        if [ -e "$part_name" ]; then
            current_size=$(stat $part_name -c%s)
            if [ $current_size -eq ${part_size[i]} ]; then                
                echo "Part $i done!"
                continue
            elif [ $current_size -ge ${part_size[i]} ]; then
                echo "Something's wrong with part $i's size. Exiting..."
                kill $(jobs -p)  
                exit              
            else
                echo "Resuming part $i!"
            fi
            part_begin=$(( i*piece_size + current_size))            
        else
            part_begin=$(( i*piece_size ))
        fi               
        
        part_end=$((i*piece_size + part_size[i] - 1))
        echo "Downloading part $i: From $part_begin till $part_end."
        curl $download_URL --location --silent --range $part_begin-$part_end >> "$part_name" &  
    done

    wait
    echo "Any cURL processes I started have ended. Let me see if the files have been downloaded completely."

    status=1    
    
    for i in `seq 0 $num_parts`; do
        part_name="`echo $file_name.$i`"
        current_size=$(stat $part_name -c%s)
        if [ $((current_size - part_size[i])) -lt 0 ]; then
            echo "In part $i, $(( part_size[i] - current_size )) bytes remain to be downloaded."
            status=$((status && 0))
        fi
    done    
    
    if [ $loop_iterations -eq 10 ]; then
        echo "Quiting the task. Something might be wrong, as this the tenth time"
        echo "I've tried downloading. Do check what's going wrong. Sorry! :("
        exit
    fi    
    
done    

echo "All files done."

cd $working_dir

if ls | grep -q "$file_name"; then
    current_size=$(stat $file_name -c%s) 
    if [ $((current_size - file_size)) -eq 0 ]; then
        echo "A file of matching size and name already exists at the site."
    fi
else
    cat $temp_dir/$file_name.* > $file_name
    downloaded_size=$(stat $file_name -c%s)

    if [ $downloaded_size -eq $file_size ]; then
        rm $temp_dir -r -f 
        echo "Done!"
    else    
        echo "Oh, damn! Something's wrong. Better check the file size."
    fi
fi
