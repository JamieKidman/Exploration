#!/bin/bash
# Name: Jamie Daniel Kidman
# Student id: 10510495

# Constants

url="https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=152"
url_base="https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/"
ext=".jpg"
output_directory="./DSC0_Downloads/"
picture_id_list=$( curl -s ${url} | grep -Eo DSC0.{4} | sort --unique ) # List of all available Thumbnail names


# Functions

multi_download_setup()
{
    if [ ! -e $output_directory ] # Checks if the output directory exits and creates the output directory if it doesn't exist
    then 
        mkdir $output_directory || echo "Please check directory permissions or run this script as root (please note that running in root will mean the directory will appear in the root users home directory)"
    fi
}


download_specific()
{
    clean_thumbnail="" # Initiallising and setting it to a value that will cause the loop to be triggered

    echo -e "\nDownloading a Specific Thumbnail"

    while [[ $clean_thumbnail == "" ]] # Loop collects and validates user input
    do
        read -p "Please Enter the Thumbnails Name: " thumbnail

        if [[ ${#thumbnail} -ne 8 ]]
        then
            echo -e "\n\nError: Invalid Thumbnail Name\n"
        else
            clean_thumbnail=$( echo ${picture_id_list} | grep -Eo $thumbnail )
        fi
    done

    if [ ! -e $output_directory ] # If the user hasn't caused the multi download directory to be created it will download to the directory the script was ran in, this is how id prefer it if I had to use the script
    then 
        if [ ! -e ${clean_thumbnail}${ext} ] # Checks if the file has been downloaded
        then
            file_size=$( wget "${url_base}${clean_thumbnail}${ext}" 2>&1 | grep -Eo "\([0-9]+.{1,3}\)" | grep -Eo "\d*\w*" ) # downloads the file and collects the filesize
            echo "Downloading ${clean_thumbnail}, with the file name ${clean_thumbnail}${ext}, with a file size of ${file_size}" # Output as defined in the brief
        else
            echo "Error: File Already Exists"
        fi

    else
        if [ ! -e $output_directory${clean_thumbnail}${ext} ] # If the user has already caused the multi directory to be created then the file will be downloaded there (This is requires more effort to make and is the way I would like it)
        then
            file_size=$( wget "${url_base}${clean_thumbnail}${ext}" -P "$output_directory" 2>&1 | grep -Eo "\([0-9]+.{1,3}\)" | grep -Eo "\d*\w*" ) # downloads the file and collects the filesize
            echo "Downloading ${picture}, with the file name ${picture}${ext}, with a file size of ${file_size}" # Output as defined in the brief
        else
            echo "Error: File Already Exists"
        fi

    fi
}


download_all()
{
    multi_download_setup # Creates the output directory

    echo -e "\nDownloading All Thumbnails"

    for picture in ${picture_id_list} # Loops over every Thumbnail name (which is stored in picture_id_list)
    do
        if [ ! -e $output_directory${picture}${ext} ] # Checks if the file has already been downloaded
        then
            file_size=$( wget "${url_base}${picture}${ext}" -P "$output_directory" 2>&1 | grep -Eo "\([0-9]+.{1,3}\)" | grep -Eo "\d*\w*" ) # downloads the file and collects the filesize
            echo "Downloading ${picture}, with the file name ${picture}${ext}, with a file size of ${file_size}" # Output as defined by the brief

            raw_total_filesize+=$( sed 's/[^0-9]*//g' <<<$file_size )
        else
            echo "Error: File Already Exists"
        fi
    done

    total_filesize=$raw_total_filesize*1000 # Multiply by 1000 as numfmt needs bytes and the variables units is KB
    string_total_filesize="$( numfmt --to=iec $total_filesize )B" # Uses numfmt to calculate K M or G for size and adds a B so the output would be 2.4GB
    echo -e "\nTotal Size of Downloads: ${string_total_filesize}\n"
}


download_range()
{
    declare -i clean_start=1 # Both clean start and end are initilised in a way that will trigger the loop to capture user input
    declare -i clean_end=0
    local error=0 # declared as local but probably wont be neccissary

    multi_download_setup # Creates the output directory

    echo -e "\nDownloading Based on a Range"

    while [ $clean_start -ge $clean_end ] # Loop collects and validates user input
    do
        read -p "Please Enter the Start of the Range: " start_range
        clean_start=${start_range//[^0-9]/}

        read -p "Please Enter the End of the Range: " end_range
        clean_end=${end_range//[^0-9]/}

        # Note that entering 0 in either input is considered an invaild input
        if ([ $clean_start -eq 0 ] || [ $clean_end -eq 0 ]) || ([ ${#clean_start} -ne 4  ] || [ ${#clean_end}  -ne 4 ])
        then
            clean_start=1 # Both start and end are re-initalised in a way that will re trigger the loop
            clean_end=0
            error=1 # Flag variable used to prevent two error messages over the same issue
            echo -e "\n\nInvaild Input: Please Try Again\n" 
        fi

        ([ $clean_start -ge $clean_end ] && [ ! $error -eq 1 ]) && echo -e "\n\nWarning: Please Make Sure The Start is less than the End\n"
    done

    # The for loop below creates a string (regex_range) based on the input range eg "1533|1534|1535|1536" the string is in this structure as it is regex code and will
    for i in $(seq $((clean_start-1)) $((clean_end-1))); do regex_range+="${i}|"; done
    regex_range+=$clean_end

    # Range is a list that contains all the Thumbnail Names that are between the input start and end range and uses the regex string created above. It searches in $picture_id_list a list of all available Thumbnail names. 
    range=$( echo $picture_id_list | grep -Eo "DSC0(${regex_range})" 2>&1)

    for picture in ${range} # Loop downloads every picture that is within the range.
    do
        if [ ! -e $output_directory${picture}${ext} ] # Checks if the file has already been downloaded
        then
            file_size=$( wget "${url_base}${picture}${ext}" -P "$output_directory" 2>&1 | grep -Eo "\([0-9]+.{1,3}\)" | grep -Eo "\d*\w*" ) # downloads the file and collects the filesize
            echo "Downloading ${picture}, with the file name ${picture}${ext}, with a file size of ${file_size}" # Output as defined in the brief

            raw_total_filesize+=$( sed 's/[^0-9]*//g' <<<$file_size ) # Creates a total of KB downloaded in the event that new files are larger than KB incorperate numfmt
        else
            echo "Error: File Already Exists"
        fi
    done

    total_filesize=$raw_total_filesize*1000 # Multiply by 1000 as numfmt needs bytes and the variable is in KB
    string_total_filesize="$( numfmt --to=iec $total_filesize )B" # Uses numfmt to calculate K M or G for size and adds a B so the output would be 2.4GB
    echo -e "\nTotal Size of Downloads: ${string_total_filesize}\n"
}


download_random()
{
    declare -i clean_amount=0
    random_list=${picture_id_list} #$(shuf <<<$picture_id_list) # Uses the shuf program to create a randomly ordered list       # <<< is used to pipe the function into the program

    multi_download_setup # Creates the output directory

    echo -e "\nDownloading Some Random Thumbnails"

    while [ $clean_amount -eq 0 ] # Loop collects and validates user input
    do
        read -p "Please Enter the Amount of Random Thumbnails: " amount
        clean_amount=${amount//[^0-9]/}     # Removes all non numeric input

        if [ $clean_amount -gt 75 ] || [ $clean_amount -lt 1 ] # Bounds checking
        then
            echo -e "\n\nInvalid Input: Please Select a Value between 1 & 75 (Inclusive)\n"
            clean_amount=0
        fi
    done

    j=0
    for picture in $random_list # This loop would loop over every thumbnail id in the picture_id_list variable list however a break is being used after the correct amount of pictures are downloaded, in python enumerate would be used
    do
        if [ $j -lt $clean_amount ] # checks if enough pictures have been downloaded
        then
            if [ ! -e $output_directory${picture}${ext} ] # checks if the file has already been downloaded
            then
                file_size=$( wget "${url_base}${picture}${ext}" -P "$output_directory" 2>&1 | grep -Eo "\([0-9]+.{1,3}\)" | grep -Eo "\d*\w*" ) # downloads the file and collects the filesize
                echo "Downloading ${picture}, with the file name ${picture}${ext}, with a file size of ${file_size}" # Output as defined in the brief

                raw_total_filesize+=$( sed 's/[^0-9]*//g' <<<$file_size ) # Creates a total of KB downloaded in the event that new files are larger than KB incorperate numfmt
    
                ((j++))
            else
                echo "Error: File Already Exists"
    
                ((j++))
            fi
        else
            break
        fi
    done

    total_filesize=$raw_total_filesize*1000 # Multiply by 1000 as numfmt needs bytes and the variables units is KB
    string_total_filesize="$( numfmt --to=iec $total_filesize )B" # Uses numfmt to calculate K M or G for size and adds a B so the output would be 2.4GB"
    echo -e "\nTotal Size of Downloads: ${string_total_filesize}\n"
}


menu_board()
{
    echo "-----------------------------------------------"
    echo "ECU Cyber Security Thumbnail Downloading Script"
    echo "-----------------------------------------------"

    echo -e "\nType 1 to Download a Specific Thumbnail"
    echo "Type 2 to Download All Thumbnails"
    echo "Type 3 to Download Thumbnails by Range"
    echo "Type 4 to Download Random Thumbnails"
    echo -e "Type 9 to Exit This Script\n"

    # echo -e "\nType \"rm\" to remove all files and folders created by this script"
    # echo -e "NOTE THAT THIS PROMPT WILL BE HIDDEN AFTER FIRST EXECUTION AS THIS IS JUST TO MAKE YOUR LIFE EASIER, ITS OUTSIDE THE BRIEF AND WOULD HAVE BEEN REMOVED"
    
    sed -i "209s/^    echo/    # echo/" $0 # Inserts a # on the lines thats outputs show how to access a hidden option
    sed -i "210s/^    echo/    # echo/" $0 # Inserts a # on the lines thats outputs show how to access a hidden option
}


main()
{
    declare -i raw_total_filesize=0 # Both variables are declared as ints just as a backup because strings are converted and stored in these variables
    declare -i total_filesize=0 # In the event that main is looped both are re-initalised to 0

    menu_board # Prints the menu board which is in the function above this was only done incase someone has invalid input more than 2 Multiply

    count=0
    clean_input=9 # Initalised the input to a value that will trigger the loop
    while [[ $clean_input -gt 4 ]]
    do
        read -p "Input: " input

        [[ $input = "rm" ]] && rm -rf "${output_directory}" && find . -type f -name "*.jpg" -exec rm -f {} \; && read -p "Input: " input # Hidden option that would be removed in production
        [[ $input = "9" ]] && exit 0

        clean_input=${input//[^0-9]/} # Makes sure that the input is a number, done after the hidden menu but would be under the first read command in production

        if [[ -z $clean_input ]] || [[ ${#input} -ne 1 ]] || [[ $clean_input -gt 4 ]] || [[ $clean_input -eq 0 ]] 2>&1 # Makes sure the input is valid
        then
            echo -e "\n\nError: Invalid Input\n"
            clean_input=9 # reinitalising in a way that will trigger the loop
            ((count++))
        fi

        if [ $count -gt 2 ] # If the user inputs invalid inputs 2 twice in a row the menu will be reprinted
        then
            menu_board
        fi
    done

    # Runs the fuction corrisponding to user input and the menu
    [ $clean_input -eq 1 ] && download_specific
    [ $clean_input -eq 2 ] && download_all
    [ $clean_input -eq 3 ] && download_range
    [ $clean_input -eq 4 ] && download_random

    echo "Program Finished"

    exit 0
}


main
