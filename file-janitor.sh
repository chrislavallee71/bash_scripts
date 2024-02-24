#!/usr/bin/env bash

filename="file-janitor.sh"
year=$(date +'%Y')
help_file="./file-janitor-help.txt"

echo "File Janitor, $year"
echo -e "Powered by Bash\n"

if [ "$1" = "help" ]; then 
    cat "$help_file"
elif [ "$1" = "list" ]; then 
    if [ -z "$2" ]; then
        echo "Listing files in the current directory"
        ls -1A | sort 
    else
        if [ -e "$2" ] && [ -d "$2" ]; then
            echo "Listing files in $2"
            ls -1A "$2" | sort
        elif [ ! -e "$2" ]; then
            echo "$2 is not found"
        elif [ ! -d "$2" ]; then
            echo "$2 is not a directory"
        fi
    fi
elif [ "$1" = "report" ]; then
        if [ -z "$2" ]; then
            echo "The current directory contains:"
            dir="."
        elif [ ! -e "$2" ]; then
            echo "$2 is not found"
            return
        elif [ ! -d "$2" ]; then
            echo "$2 is not a directory"
            return
        else
            echo "$2 contains:"
            dir="$2"
        fi
        
        # Count files and report total size
        for x in tmp log py; do
            file_count=$(find "$dir" -maxdepth 1 -type f -name "*.$x" | wc -l)
            total_size=$(find "$dir" -maxdepth 1 -type f -name "*.$x" -printf "%s\n" | awk '{sum += $1} END {print sum}')
            printf "%d %s file(s), with total size of %d bytes\n" "$file_count" "$x" "$total_size"
        done
elif [ "$1" = "clean" ]; then
        if [ -z "$2" ]; then
            echo "Cleaning the current directory..."
            dir="."
        elif [ ! -e "$2" ]; then
            echo "$2 is not found"
            exit 1
        elif [ ! -d "$2" ]; then
            echo "$2 is not a directory"
            exit 1
        else
            echo "Cleaning $2..."
            dir="$2"
        fi
    
        # Delete old *.log files
        del_log=$(find "$dir" -maxdepth 1 -type f -name "*.log" -mtime +3 -exec rm {} \; -print | wc -l)
        echo "Deleting old log files... done! $del_log files have been deleted"
    
        # Delete old *.tmp files
        del_tmp=$(find "$dir" -maxdepth 1 -type f -name "*.tmp" -exec rm {} \; -print | wc -l)
        echo "Deleting temporary files... done! $del_tmp files have been deleted"
    
        # Move *.py files to subdirectory
        py_subdir="$dir/python_scripts"
        
        # Check if any .py files exist before attempting to move them
        py_files_found=$(find "$dir" -maxdepth 1 -type f -name "*.py" -print -quit)
        if [ -n "$py_files_found" ]; then
            if [ -d "$py_subdir" ]; then
                moved_py=$(find "$dir" -maxdepth 1 -type f -name "*.py" -exec mv {} "$py_subdir" \; -print | wc -l)
            else
                mkdir -p "$py_subdir"
                moved_py=$(find "$dir" -maxdepth 1 -type f -name "*.py" -exec mv {} "$py_subdir" \; -print | wc -l)
            fi
        
            # Adjust output message based on the number of files moved
            if [ "$moved_py" -gt 0 ]; then
                echo "Moving python files... done! $moved_py files have been moved"
            fi
        else
            echo "Moving python files... done! 0 files have been moved"
        fi
        
        if [ "$dir" == "." ]; then
            echo "Clean up of the current directory is complete!"
        elif [ $moved_py -gt 1 ]; then
            echo "Clean up of $dir is complete!"
        else
            false
        fi
else 
    echo "Type $filename help to see available options"
fi
