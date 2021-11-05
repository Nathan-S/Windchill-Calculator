#!/bin/bash
#initialize variables
celsiusIn=False
celsiusOut=False
quiet=False
file="null"
filebool=1
airtemper=0
airtempbool=1
veloc=0
velocitybool=1
#help method that is called when the help is entered in the command line
help() {
    #these if statements ensure that no other arguments were entered in addition to help otherwise it exit 2
    if [ $airtempbool -eq 0 ] || [ $velocitybool -eq 0 ]
    then
        echo "Invalid Arguments"
        echo "Help Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    if [ $filebool -eq 0 ] || [ $quiet == true ]
    then
        echo "Invalid Arguments"
        echo "Help Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    if [ $celsiusIn == true ] || [ $celsiusOut == true ]
    then
        echo "Invalid Arguments"
        echo "Help Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    #prints help information
    echo "Wind-Chill Calculator"
    echo ""
    echo "Usage: windchill --airtemp=<temp> --velocity=<speed> [-c | --cout] [--cin] [--file=<filename>] [-h | --help] [-q | --quiet] [-v | --version]"
    echo""
    echo "Arguments"
    echo "--airtemp=<temp>    The outside air temperature (in Fahrenheit by default)"
    echo "--velocity=<speed>  The wind speed"
    echo "-c | --cout         Display the wind-chill value in Celsius rather than Fahrenheit (Fahrenheit output is default)"
    echo "--cin               The --airtemp value is in Celsius rather than Fahrenheit"
    echo "--file=<filename>   Write all output to the specified file rather than the command line"
    echo "-h | --help         Display this message"
    echo "-q | --quiet        Do not display anything except the answer in the output"
    echo "-v | --version      Display the version information"
}

version() {
    #Checks that no other arguments were entered in with version
    if [ $airtempbool -eq 0 ] || [ $velocitybool -eq 0 ]
    then
        echo "Invalid Arguments"
        echo "Version Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    if [ $filebool -eq 0 ] || [ $quiet == true ]
    then
        echo "Invalid Arguments"
        echo "Version Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    if [ $celsiusIn == true ] || [ $celsiusOut == true ]
    then
        echo "Invalid Arguments"
        echo "Version Can Not Be Accessed With Other Parameters"
        exit 2
    fi
    #prints version information
    echo "Version 1.0"
    echo "Nathanial Smith"
    echo "Date: October 16th, 2020"
    echo "Copyright (C) Professor Littleton's Lab7 Assignment"
    echo ""
}
#makes a file with the given name
mkfile() {
    #these if statements ensure that the file name is not equal to the names of the other commands, If it is, that means the filename parameters were not entered correctly
    if [ "$file" == "-q" ] || [ "$file" == "-quiet" ]
    then
        echo "Missing Filename Argument"
        echo ""
        echo "Usage: windchill --airtemp=<temp> --velocity=<speed> [-c | --cout] [--cin] [--file=<filename>] [-h | --help] [-q | --quiet] [-v | --version]"
        echo "Try 'windchill --help' for more information."
        exit 3
    fi
    if [ "$file" == "-c" ] || [ "$file" == "-cout" ]
    then
        echo "Missing Filename Argument"
        echo ""
        echo "Usage: windchill --airtemp=<temp> --velocity=<speed> [-c | --cout] [--cin] [--file=<filename>] [-h | --help] [-q | --quiet] [-v | --version]"
        echo "Try 'windchill --help' for more information."
        exit 3
    fi
    if [ "$file" == "-cin" ] || [ "$file" == "-" ]
    then
        echo "Missing Filename Argument"
        echo ""
        echo "Usage: windchill --airtemp=<temp> --velocity=<speed> [-c | --cout] [--cin] [--file=<filename>] [-h | --help] [-q | --quiet] [-v | --version]"
        echo "Try 'windchill --help' for more information."
        exit 3
    fi
    touch $file
    filebool=0
}
#these are exit cases based on the required arguments airtemp and velocity
exitCases() {
    if [[ $airtempbool == 1 && $velocitybool == 1 ]]
    then
        echo "Missing Outside Air Temperature Argument And Wind Speed Argument"
        exit 3
    fi

    if [ $airtempbool == 1 ]
    then
        echo "Missing Outside Air Temperature Argument"
        exit 3
    fi

    if [ $velocitybool == 1 ]
    then
        echo "Missing Wind Speed Argument"
        exit 3
    fi

    if [ $airtemper -lt -58 ] || [ $airtemper -gt 41 ]
    then
        printf "Outside Air Temperature (%d) is Out of Range [-58 to 41]" $airtemper
        exit 4
    fi

    if [ $veloc -lt 2 ] || [ $veloc -gt 50 ]
    then
        printf "Windspeed (%d) is Out of Range [2 to 50]" $veloc
        exit 4
    fi
}
#this is the getopt line that decides which short and long arguments are valid and the ":" determines which arguments require additional arguments
Parsed=$(getopt -n "$0" -o chqv --long "airtemp:,velocity:,cout,cin,file:,help,quiet,version" -- "$@")
#this evaluates the set
eval set -- "$Parsed"
#if the exit case is not equal to 0 then it exits with 1
if [ $? -ne 0 ]
then
    echo "Unknown Arguments"
    exit 1
fi

#this is a case statement that goes through all of the arguments and shifts the arguments to the left accordingly until "--" is hit

while true
do
    case "$1" in
        -h | --help)
            help
            break;;
        -v | --version)
            version
            break;;
        --airtemp)
            airtemper=$2
            airtempbool=0
            shift 2;;
        --velocity)
            veloc=$2
            velocitybool=0
            shift 2;;
        --file) #still need to check if the file parameters are correct
            file=$2
            filebool=0
            mkfile
            shift 2;;
        -c | --cout)
            if [ $celsiusOut == true ]
            then
                echo "Invalid Arguments"
                echo ""
                echo "Usage: windchill --airtemp=<temp> --velocity=<speed> [-c | --cout] [--cin] [--file=<filename>] [-h | --help] [-q | --quiet] [-v | --version]"
                echo "Try 'windchill --help' for more information."
                exit 2
            fi
            celsiusOut=true
            shift;;
        --cin)
            celsiusIn=true
            shift;;
        -q | --quiet)
            quiet=true
            shift;;
        --) #paremeter end, stop looping
            break;;
        *)
            echo "Error: Unknown Argument!"
            exit 1;;
    esac

done
#calls exitcases just to ensure that the file exits if the required parameters are not hit
exitCases
#This first if statement hits if --quiet was entered and the file name was not entered
if [ $quiet == true ] && [ $filebool -eq 1 ]
then
    if [ $celsiusIn == true ] && [ $celsiusOut != true ]
    then
        airtemper=$((airtemper*9/5+32))
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "\n%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn != true ]
    then
        airtemper=`echo "($airtemper-32)*5/9" | bc -l`
	    pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "\n%.3f\n" $windchill
    fi
    
    if [ $celsiusOut != true ] && [ $celsiusIn != true ]
    then
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "\n%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn == true ]
    then
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "\n%.3f\n" $windchill
    fi
#this elif statement hits if quiet is false and file was entered
elif [ $quiet == False ] && [ $filebool -eq 0 ]
then
	echo ""
    echo "Wind-Chill Calculator" >> $file
    echo "Wind-Chill Calculator"
    if [ $celsiusIn == true ] && [ $celsiusOut != true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper >> $file
        printf "Outside Air Temperature (C): %d\n" $airtemper
        airtemper=$((airtemper*9/5+32))
        printf "Wind Speed: %d\n" $veloc >> $file
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (F): " >> $file
        printf "Wind-Chill (F): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill >> $file
        printf "%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn != true ]
    then
	    printf "Outside Air Temperature (F): %d\n" $airtemper >> $file
        printf "Outside Air Temperature (F): %d\n" $airtemper
        airtemper=`echo "($airtemper-32)*5/9" | bc -l`
	    printf "Wind Speed: %d\n" $veloc >> $file
        printf "Wind Speed: %d\n" $veloc
	    pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (C): " >> $file
        printf "Wind-Chill (C): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill >> $file
        printf "%.3f\n" $windchill
    fi
    
    if [ $celsiusOut != true ] && [ $celsiusIn != true ]
    then
        printf "Outside Air Temperature (F): %d\n" $airtemper >> $file
        printf "Outside Air Temperature (F): %d\n" $airtemper
        printf "Wind Speed: %d\n" $veloc >> $file
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (F): " >> $file
        printf "Wind-Chill (F): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill >> $file
        printf "%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn == true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper >> $file
        printf "Outside Air Temperature (C): %d\n" $airtemper
        printf "Wind Speed: %d\n" $veloc >> $file
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (C): " >> $file
        printf "Wind-Chill (C): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill >> $file
        printf "%.3f\n" $windchill
    fi
#this elif statement hits if --quiet is entered and the file was entered
elif [ $quiet == true ] && [ $filebool -eq 0 ]
then
    echo "Wind-Chill Calculator" >> $file
    if [ $celsiusIn == true ] && [ $celsiusOut != true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper >> $file
        airtemper=$((airtemper*9/5+32))
        printf "Wind Speed: %d\n" $veloc >> $file
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (F): " >> $file
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill >> $file
        printf "\n%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn != true ]
    then
	    printf "Outside Air Temperature (F): %d\n" $airtemper >> $file
        airtemper=`echo "($airtemper-32)*5/9" | bc -l`
	    printf "Wind Speed: %d\n" $veloc >> $file
	    pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (C): " >> $file
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill >> $file
        printf "\n%.3f\n" $windchill
    fi
    
    if [ $celsiusOut != true ] && [ $celsiusIn != true ]
    then
        printf "Outside Air Temperature (F): %d\n" $airtemper >> $file
        printf "Wind Speed: %d\n" $veloc >> $file
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (F): " >> $file
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill >> $file
        printf "\n%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn == true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper >> $file
        printf "Wind Speed: %d\n" $veloc >> $file
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (C): " >> $file
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill >> $file
        printf "\n%.3f\n" $windchill
    fi
#else --quiet was not entered and --file wasn't entered
else
    echo ""
    echo "Wind-Chill Calculator"
    if [ $celsiusIn == true ] && [ $celsiusOut != true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper
        #convert Celsius to Farenheit
        airtemper=$((airtemper*9/5+32))
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (F): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn != true ]
    then
        #convert from Farenheit to Celsius
	    printf "Outside Air Temperature (F): %d\n" $airtemper
        airtemper=`echo "($airtemper-32)*5/9" | bc -l`
	    printf "Wind Speed: %d\n" $veloc
	    pow=`echo "e(l($veloc)*0.16)" | bc -l`
	    printf "Wind-Chill (C): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
	    printf "%.3f\n" $windchill
    fi
    
    if [ $celsiusOut != true ] && [ $celsiusIn != true ]
    then
        printf "Outside Air Temperature (F): %d\n" $airtemper
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (F): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill
    fi

    if [ $celsiusOut == true ] && [ $celsiusIn == true ]
    then
        printf "Outside Air Temperature (C): %d\n" $airtemper
        printf "Wind Speed: %d\n" $veloc
        pow=`echo "e(l($veloc)*0.16)" | bc -l`
        printf "Wind-Chill (C): "
	    windchill=`echo "35.74+0.6215*$airtemper-35.75*$pow+0.4275*$airtemper*$pow" | bc -l`
        printf "%.3f\n" $windchill
    fi

fi
