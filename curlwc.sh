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

GREP_OPTIONS=

status=0
temp_dir=".tempdir"

if [[ -z $1 ]]; then
    echo "Usage: "
    echo "<script name> URL [Target Directory] [piece size in MB]"
    echo "Please specify a URL to download, if you still wanna continue."
    read download_URL
else
    download_URL="$1"
fi

working_dir="${2:-$PWD}"

piece_size=$((${3:-149}*1024*1024))

cd "$working_dir"

file_size=$(( $(curl "$download_URL" -s -I -L | awk '/Content-Length:/ {print $2}') ))

num_parts=$((file_size / piece_size))
part_size[$num_parts]=$((file_size % piece_size))

mkdir -p "$temp_dir"
cd "$temp_dir"

for ((i = 0; i < (num_parts - 1); i++)); do
        part_size[$i]="$piece_size"
done

shopt -s nullglob
shopt -s dotglob

files=( *.0 )
case ${#files[@]} in
	0)
		filename=${download_URL##*/}
		filename=${download_URL%%\?*}
		mv "$filename" -T "${files[0]}.0"
		;;
	1)
		file_name=${files[0]%".0"}
		;;
	*)
		echo "multiple initial parts found. Quitting..."
		exit 1
		;;
esac

while ((status == 0)); do
	loop_iterations=$((loop_iterations + 1))
            
	for ((i = 0; i < num_parts; i++))
	do
        part_name="$file_name.$i"
        
        if [[ -e "$part_name" ]]; then
            current_size=$(stat "$part_name" -c%s)
            if (( current_size == part_size[i] )); then                
                echo "Part $i done!"
                continue
            elif (( current_size > part_size[i] )); then
                echo "Something's wrong with part $i's size. Exiting..."
                kill $(jobs -p)  
                exit              
            else
                echo "Resuming part $i!"
            fi
            part_begin=$((i * piece_size + current_size))            
        else
            part_begin=$((i * piece_size))
        fi               
        
        part_end=$((i*piece_size + part_size[i] - 1))
        echo "Downloading part $i: From $part_begin till $part_end."
        curl "$download_URL" --location --silent --range $part_begin-$part_end >> "$part_name" &  
    done

    wait
    echo "Any cURL processes I started have ended. Let me see if the files have been downloaded completely."

    status=1    
    
	for ((i = 0; i < num_parts; i++))
	do
        part_name="$file_name.$i"
        current_size=$(stat "$part_name" -c%s)
		if (( (current_size - part_size[i]) > 0 )); then
            echo "In part $i, $(( part_size[i] - current_size )) bytes remain to be downloaded."
            status=$((status && 0))
        fi
    done    
    
    if (( loop_iterations == 10 )); then
        echo "Quiting the task. Something might be wrong, as this the tenth time"
        echo "I've tried downloading. Do check what's going wrong. Sorry! :("
        exit
    fi    
    
done    

echo "All files done."

cd "$working_dir"

if [[ -f $file_name ]]; then
    current_size=$(stat "$file_name" -c%s) 
	if (( (current_size - file_size) > 0 )); then
        echo "A file of matching size and name already exists at the site."
    fi
else
    printf "$temp_dir/$file_name.%d\0" ${!part_size[@]} | xargs -0 cat > "$file_name"
    downloaded_size=$(stat "$file_name" -c%s)

	if (( downloaded_size == file_size )); then
        rm $temp_dir -r -f 
        echo "Done!"
    else    
        echo "Oh, damn! Something's wrong. Better check the file size."
    fi
fi
