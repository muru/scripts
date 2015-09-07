#! /bin/bash

windows_chars='<>:"\|?*'
prefix="windows/"

# Find number of files/directories which has this name as a prefix
find_num_files ()
(
	if [[ -e $prefix$1$2 ]]
	then
		shopt -s nullglob
		files=( "$prefix$1-"*"$2" )
		echo ${#files[@]}
	fi
)

# From http://www.shell-fu.org/lister.php?id=542
# Joins strings with a separator. Separator not present for
# edge case of single string.
str_join ()
(
	IFS=${1:?"Missing separator"}
	shift
	printf "%s" "$*"
)

for i
do
	# convert to lower case, then replace special chars with _
	new_name=$(tr "$windows_chars" _ <<<"${i,,}")

	# if a directory, make it, instead of copying contents
	if [[ -d $i ]]
	then
		mkdir -p "$prefix$new_name"
		echo mkdir -p "$prefix$new_name"
	else
		# get filename without extension
		name_wo_ext=${new_name%.*}
		# get extension
		# The trick is to make sure that, for:
		# "a.b.c", name_wo_ext is "a.b" and ext is ".c"
		# "abc", name_wo_ext is "abc" and ext is empty
		# Then, we can join the strings without worrying about the
		# . before an extension
		ext=${new_name#$name_wo_ext}
		count=$(find_num_files "$name_wo_ext" "$ext")
		name_wo_ext=$(str_join - "$name_wo_ext" $count)
		cp "$i" "$prefix$name_wo_ext$ext"
		echo cp "$i" "$prefix$name_wo_ext$ext"
	fi
done
