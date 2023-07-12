#!/bin/sh
# set -e

PROCESS=true
#out file of process time
ProcessCsv="$FolderOutputEnv/Process.csv"
# Infinite loop to continuously search for files
while $PROCESS; do
    # Use the 'find' command to search for files in the specified folder and ignore hide files
    # CheckFiles=`find $FolderInputEnv -name "[!.]*" -type f`
    if ls -A "$FolderInputEnv"/* >/dev/null 2>&1;
    then
        # Give all permissions 
        chmod 777 $FolderInputEnv/*
        echo "Files exist in the folder."
        # Loop through each file in the folder
        for file_path in "$FolderInputEnv"/*; do
            # Extract the file name without extension
            file_name=$(basename "$file_path")
            file_name_filter="${file_name%.*}"
            # Get the file size in a human-readable format
            file_size_human=$(du -h "$file_path" | awk '{print $1}')
            start_time=$(date +%s)  # Get the current timestamp in seconds - start
            # run process
            abricate $file_path
            end_time=$(date +%s) # Get the current timestamp in seconds - end
            execution_time=$((end_time - start_time)) # Calculate the execution time difference vector
            echo "Process executed in $execution_time seconds."
            abricate $file_path --csv > "$FolderOutputEnv/$file_name_filter.csv"
            # move file processed
            mv "$file_path" "$FolderProcessedEnv/"
            
            #valid if exist logs process file
            if [ -f "$ProcessCsv" ]; then
                echo "$file_path,$execution_time,$file_size_human" >> $ProcessCsv
            else
                echo "Process.csv init logs"
                echo "FileName,TimeSecs,SizeFile" > $ProcessCsv
                echo "$file_path,$execution_time,$file_size_human" >> $ProcessCsv
            fi
        done
    else
        echo "No files found in the folder."
    fi

    # Sleep for a certain duration before the next iteration
    sleep 10
done

# exec "$@"