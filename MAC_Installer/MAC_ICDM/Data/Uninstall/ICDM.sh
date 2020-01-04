MANUFACTURER="Samsung"
PRODUCT="ICDM"
TARGET_FOLDER="/Library/Image Capture/Devices"
AGENT_FOLDER="/Library/Application Support/Samsung/TWAIN Discovery/__ModelName__"
BUNDLE_NAME="Samsung Scanner.app"
RECEIPTS_REMOVE_COMMAND="ReceiptsRemove com.samsung.icdm.*"


################################## helper functions

# $1 - full path to source directory (directory itself not removed)
# $2 - wildcard or file/dir name
function DirectoryRemoveSubset()
{
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "DirectoryRemoveSubset [$2] from [$1]"
	fi
	
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		find "$1" -name "$2" -execdir rm -rfv {} \;	# debug ( verbose output )
	else
		find "$1" -name "$2" -execdir rm -rf {} \;	
	fi
}

# $1 - full path to source directory
function RemoveWithContents()
{
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "RemoveWithContents [$1]"
	fi
	
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		rm -rfv "$1"	# debug ( verbose output )
	else
		rm -rf "$1"	
	fi
}

# $1 - message
# $2 - start time, as in `date +%s`
# $3 - end time, as in `date +%s`
function ElapsedTimePrint()
{
	local elapsed=`expr $3 - $2`
	local elapsed_min=`expr $elapsed / 60`
	local elapsed_sec=`expr $elapsed % 60`

	echo "$1 $elapsed s ($elapsed_min min $elapsed_sec s)."
}

# $1 - package name; wildcards allowed
function ReceiptsRemove()
{
	local oldFoldePath="/Library/Receipts"
	DirectoryRemoveSubset "$oldFoldePath" "$1"
	if [ $? -ne 0 ] ; then
			printf "warning:  !!!  cannot remove $oldFoldePath/$1 !!!\n"
	#		exit 1
	fi

	local newFoldePath="/var/db/receipts"
	DirectoryRemoveSubset "$newFoldePath" "$1"
	if [ $? -ne 0 ] ; then
			printf "warning:  !!!  cannot remove $newFoldePath/$1 (OK on Mac OS 10.5)   !!!\n"
	#		exit 1
	fi
}

################################## main script body

###### set up itself

# set to 1 for debugging
DETAIL_LEVEL=0


# parse command line
thisScriptPath=$0
thisScriptName=`basename "${thisScriptPath}"`
thisScriptFolder=`dirname "${thisScriptPath}"`

FULL_SOFTWARE_PRODUCT_NAME="$MANUFACTURER $PRODUCT"

#. "${thisScriptFolder}/Uninstall Include.sh"

# determine product name

#`cat "$packageResourcesDir/Info.plist" | grep CFBundleName -A1 | tail -1 | sed 's.*<string>' | sed 's</string>' | awk '{print $0}' | tr -d "\r"`


# check user permissions
MY_UID=`/usr/bin/id -u`
if [ "$MY_UID" != "0" ]
then
	echo
	echo "You should have root privileges in order to uninstall $FULL_SOFTWARE_PRODUCT_NAME."
	echo "Please login as root or use an utility 'su' or 'sudo' when you run ${thisScriptPath}." 
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "Current UID: $MY_UID."
	fi		
	exit 2
else
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "root UID: $MY_UID."
	fi		
fi

# print startup date
echo "$FULL_SOFTWARE_PRODUCT_NAME Uninstall - started at `date`"
TIME_BEGIN=`date +%s`




# remove the files from directories for different destinations and conditions


DirectoryRemoveSubset "$TARGET_FOLDER" "$BUNDLE_NAME"
if [ $? -ne 0 ]
then
	printf "warning:  cannot remove [$BUNDLE_NAME] from [$TARGET_FOLDER]\n"
#	exit 1
fi

###### remove PackageMaker stuff files
$RECEIPTS_REMOVE_COMMAND

# remove itself
unlink "${thisScriptPath}"



# remove containing folder if no .sh files available.
listSh=`find "$thisScriptFolder" -name "*.sh" -print`

if [ "$listSh" = "" ]
then
	echo "info: removing parent folder"
	RemoveWithContents "$thisScriptFolder"	
fi

# remove upper-level folder (Common for ICDM, Model for TWAIN)
upperFolderPath=`dirname "${thisScriptFolder}"`
upperFolderName=`basename "${upperFolderPath}"`
if [ "1" = "$DETAIL_LEVEL" ] ; then
	echo "info: upperFolderName: ${upperFolderName}"
fi

listUpper=`find "${upperFolderPath}" -type d -print`
echo "listUpper: .$listUpper."
if [ "$listUpper" = "" ] || [ "$listUpper" = "${upperFolderPath}" ]
then
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "info: removing upper folder 1"
	fi
	RemoveWithContents "$upperFolderPath"
fi

# remove upper-level folder (Uninstall for TWAIN)
if [ "${upperFolderName}" = "Model" ]
then
	upperFolderPath2=`dirname "${upperFolderPath}"`
	upperFolderName2=`basename "${upperFolderPath2}"`
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "info: upperFolderName2: ${upperFolderName2}"
	fi
	listUpper2=`find "$upperFolderPath2" -type d -print`
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "info: listUpper2: .$listUpper2."
	fi
	if [ "$listUpper2" = "" ] || [ "$listUpper2" = "${upperFolderPath2}" ]
	then
		if [ "1" = "$DETAIL_LEVEL" ] ; then
			echo "info: removing upper folder 2"
		fi
		RemoveWithContents "$upperFolderPath2"
	fi
fi


# optionally remove the USD agent folder
if [ -z "$AGENT_FOLDER" ]
then
	if [ "1" = "$DETAIL_LEVEL" ] ; then
		echo "info: no agent folder specified"
	fi
else
	if [ -d "$AGENT_FOLDER" ]
	then
		if [ "1" = "$DETAIL_LEVEL" ] ; then
			echo "info: removing agent folder"
		fi
		RemoveWithContents "$AGENT_FOLDER"

		# remove upper-level folder (TWAIN Discovery)
		upperFolderPath3=`dirname "${AGENT_FOLDER}"`
		if [ "1" = "$DETAIL_LEVEL" ] ; then
			echo "info: removing upper folder 3 $upperFolderPath3"
		fi
		rmdir "$upperFolderPath3"
		if [ $? -ne 0 ]
		then
			if [ "1" = "$DETAIL_LEVEL" ] ; then
				echo "warning: don't try to remove upper-level folder"
			fi
		else
			# remove upper-level folder (vendor's)
			upperFolderPath4=`dirname "${upperFolderPath3}"`
			if [ "1" = "$DETAIL_LEVEL" ] ; then
				echo "info: removing upper folder 4 $upperFolderPath4"
			fi
			rmdir "$upperFolderPath4"		
		fi
	else
		if [ "1" = "$DETAIL_LEVEL" ] ; then
			echo "info: no agent folder to remove"
		fi
	fi
fi


# print finish date
TIME_END=`date +%s`
echo
ElapsedTimePrint "$FULL_SOFTWARE_PRODUCT_NAME Uninstall - finished at `date`. Total uninstall time:" "$TIME_BEGIN" "$TIME_END"
