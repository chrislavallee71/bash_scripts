#!/usr/bin/env bash

# AES-256 CIPHER USING OPENSSL


re_message='^[A-Z ]+$'
re_filename='^[a-zA-Z.]+$'
password="Pass"

menu(){
    echo "0. Exit"
    echo "1. Create a file"
    echo "2. Read a file"
    echo "3. Encrypt a file"
    echo "4. Decrypt a file"
    echo "Enter an option:"
    read -r option
}

echo "Welcome to the Enigma!"
while true; do
    menu
    case $option in
        0)
            echo "See you later!"
            break
            ;;
        1)
            while true; do
                echo "Enter the filename:"
                read -r filename
                if [[ "$filename" =~ $re_filename ]]; then 
                    echo "Enter a message:"
                    read -r message
                    if [[ "$message" =~ $re_message ]]; then
                        echo "$message" > "$filename"
                        echo "The file was created successfully!"
                        break
                    else
                        echo "This is not a valid message!"
                        break
                    fi
                else 
                    echo "File name can contain letters and dots only!"
                    break
                fi
            done
            ;;
        2)
            while true; do 
                echo "Enter the filename:"
                read -r filename
                if [[ -f "$filename" ]]; then
                    echo "File content:"
                    cat "$filename"
                    break
                else
                    echo "File not found!"
                    break
                fi
            done
            ;;
        3)
            echo "Enter the filename:"
            read -r filename
            if [[ -f "$filename" ]]; then
                echo "Enter password:"
                read -r pass_attempt
                if [[ "$pass_attempt" == "$password" ]]; then
                    outfile="${filename}.enc"
                    # Use the AES-256 cipher in CBC mode for encryption
                    openssl enc -aes-256-cbc -e -pbkdf2 -nosalt -in "$filename" -out "$outfile" -pass pass:"$password" &>/dev/null
                     exit_code=$?
                    if [[ $exit_code -eq 0 ]]; then
                        rm "$filename"
                        echo "Success"
                    fi
                 else
                    echo "Fail"
                fi
            else
                echo "File not found!"
            fi
            ;;

        4)
            echo "Enter the filename:"
            read -r filename
            if [[ -f "$filename" ]]; then
                echo "Enter password:"
                read -r pass_attempt
                if [[ "$pass_attempt" == "$password" ]]; then
                    outfile="${filename%.enc}"
                    # Use the AES-256 cipher in CBC mode for decryption
                    openssl enc -aes-256-cbc -d -pbkdf2 -nosalt -in "$filename" -out "$outfile" -pass pass:"$password" &>/dev/null
                    exit_code=$?
                    if [[ $exit_code -eq 0 ]]; then
                        rm "$filename"
                        echo "Success"
                    fi
                else
                    echo "Fail"
                fi
            else
                echo "File not found!"
            fi
            ;;
        *)
            echo -e "Invalid option!"
            ;;
    esac
done


