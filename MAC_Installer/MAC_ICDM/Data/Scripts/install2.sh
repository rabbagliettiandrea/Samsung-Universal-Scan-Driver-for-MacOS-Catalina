#!/bin/sh

# $1 - full path to directory
function FolderReCreate()
{
	echo "FolderReCreate [$1]"

	if [ -d "$1" ]
	then
		#sudo 
		rm -fr "$1"
		if [ $? -ne 0 ]
		then
			printf "error:  !!!  \"$1\" rm failed   !!!\n"
			return 1
		fi
	fi
	
	#echo -e "     Create:"
	mkdir -pv "$1"
	if [ $? -ne 0 ]
	then
		printf "error:  !!!  \"$1\" mkdir failed   !!!\n"
		return 1
	fi
}


# $1 - full path to source directory (directory itself not removed)
# $2 - wildcard or file/dir name
function FolderRemoveSubset()
{
	echo "FolderRemoveSubset [$2] from [$1]"
#	find -d "$1" -name "$2" -execdir rm -rfv {} \;	
	find -d "$1" -name "$2" -execdir rm -rf {} \;
	if [ "$DETAIL_LEVEL" -ge "2" ] ; then
		echo "info FolderRemoveSubset - destination directory contents at exit:"
		ls -l "$1"
	fi
}

# $1 - full path to source directory (directory itself not copied)
# $2 - full path to destination directory
# $3 - wildcard or file/dir name
function FolderCopySubset()
{
	local _sourceDirectory=$1
	local _destinationDirectory=$2
	local _wildcard=$3
	
	if [ -z "$_sourceDirectory" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopySubset: empty source directory path passed!"
			echo "Pass in the first function parameter the full path to source directory."
		fi
		return 1
	fi

	if [ -d "$_sourceDirectory" ] ; 
	then : # do nothing
	else
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopySubset: source directory \"$_sourceDirectory\" not found!"
			echo "Pass in the first function parameter the full path to existing source directory."
		fi
		return 1
	fi


	if [ -z "$_destinationDirectory" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopySubset: empty destination directory path passed!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi

	if [ -d "$_destinationDirectory" ] ;
	then : # do nothing
	else		
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopySubset: destination directory \"$_destinationDirectory\" not found!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi
	
	if [ -z "$_wildcard" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopySubset: empty wildcard passed!"
			echo "Pass in the third function parameter the path or wildcard."
		fi
		return 3
	fi

	

	if [ "$DETAIL_LEVEL" -ge "1" ] ; then
		echo "info FolderCopySubset() \"$_sourceDirectory/$_wildcard\" to \"$_destinationDirectory\""
		(cd "$_sourceDirectory"; tar cf - "./$_wildcard") | (cd "$_destinationDirectory"; tar xfv -)
	else
		(cd "$_sourceDirectory"; tar cf - "./$_wildcard") | (cd "$_destinationDirectory"; tar xf -)
	fi
	if [ $? -ne 0 ] ; then
		echo "error FolderCopySubset: tar failed!"
		return 4
	fi

	if [ "$DETAIL_LEVEL" -ge "2" ] ; then
		echo "info FolderCopySubset - destination directory contents at exit:"
		ls -l "$_destinationDirectory"
	fi
}

function CopyFileIfMissingOrNewer() 
{
	local sourceFolderPath=$1
	local destinationFolderPath=$2
	local filename=$3
	
	echo "sourceFolderPath \"$sourceFolderPath\" destinationFolderPath \"$destinationFolderPath\" filename \"$filename\""
}

# export -f foo
# find ... -exec bash -c 'foo "$@"' bash {} +

# $1 - full path to source directory (directory itself not copied)
# $2 - full path to destination directory
# $3 - wildcard or file/dir name
function FolderCopyFilesSafe()
{
	local sourceFolderPath=$1
	local destinationFolderPath=$2
	local wildcard=$3
	local currentFolderPath=`pwd`
	
	if [ -z "$sourceFolderPath" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyFilesSafe: empty source directory path passed!"
			echo "Pass in the first function parameter the full path to source directory."
		fi
		return 1
	fi

	if [ -d "$sourceFolderPath" ] ; 
	then : # do nothing
	else
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyFilesSafe: source directory \"$sourceFolderPath\" not found!"
			echo "Pass in the first function parameter the full path to existing source directory."
		fi
		return 1
	fi


	if [ -z "$destinationFolderPath" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyFilesSafe: empty destination directory path passed!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi

	if [ -d "$destinationFolderPath" ] ;
	then : # do nothing
	else		
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyFilesSafe: destination directory \"$destinationFolderPath\" not found!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi
	
	if [ -z "$wildcard" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyFilesSafe: empty wildcard passed!"
			echo "Pass in the third function parameter the path or wildcard."
		fi
		return 3
	fi
	
	
	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo "info FolderCopyFilesSafe - source folder contents at enter:"
		ls -l "$sourceFolderPath"
		echo
	fi
	
	cd "${destinationFolderPath}"
#	echo "dest `pwd`"
	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
#		find "${sourceFolderPath}" -name "${wildcard}" -type f -exec sh -c 'exec cp -vnp "$@" "${destinationFolderPath}"' inline {} +
		find "${sourceFolderPath}" -name "${wildcard}" -type f -exec sh -c 'exec cp -vnp "$@" "."' inline {} +
	else
		find "${sourceFolderPath}" -name "${wildcard}" -type f -exec sh -c 'exec cp -np "$@" "."' inline {} +
	fi
#	res=$?
	cd "${currentFolderPath}"

	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo
		echo "info FolderCopyFilesSafe - destination folder contents at exit:"
		ls -l "$destinationFolderPath"
	fi
#	return ${res}
}


function FolderCopyNewerFilesSafe()
{
	local sourceFolderPath=$1
	local destinationFolderPath=$2
	local wildcard=$3
#	local tempFolder=$4
	local currentFolderPath=`pwd`
	
	if [ -z "$sourceFolderPath" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyNewerFilesSafe: empty source directory path passed!"
			echo "Pass in the first function parameter the full path to source directory."
		fi
		return 1
	fi

	if [ -d "$sourceFolderPath" ] ; 
	then : # do nothing
	else
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyNewerFilesSafe: source directory \"$sourceFolderPath\" not found!"
			echo "Pass in the first function parameter the full path to existing source directory."
		fi
		return 1
	fi


	if [ -z "$destinationFolderPath" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyNewerFilesSafe: empty destination directory path passed!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi

	if [ -d "$destinationFolderPath" ] ;
	then : # do nothing
	else		
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyNewerFilesSafe: destination directory \"$destinationFolderPath\" not found!"
			echo "Pass in the second function parameter the full path to destination directory."
		fi
		return 2
	fi
	
	if [ -z "$wildcard" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error FolderCopyNewerFilesSafe: empty wildcard passed!"
			echo "Pass in the third function parameter the path or wildcard."
		fi
		return 3
	fi
	
#	if [ -z "$tempFolder" ] ; then
#		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
#			echo "error FolderCopyNewerFilesSafe: empty tempFolder passed!"
#			echo "Pass in the fourth function parameter the path to tempFolder."
#		fi
#		return 4
#	fi
	
	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo "info FolderCopyNewerFilesSafe - source folder contents at enter:"
		ls -l "$sourceFolderPath"
		echo
	fi
	
	temporaryFolderPath="/tmp"
	temporaryFilePath="${temporaryFolderPath}/1.txt"
	rm -f "${temporaryFilePath}"
	rm -f "/tmp/3.txt"
	
#	operationFilePath="${temporaryFolderPath}/2.txt"
	
	find "${sourceFolderPath}" -name "${wildcard}" -type f -print > "${temporaryFilePath}"

#	cd "${destinationFolderPath}"
	cd "${sourceFolderPath}"
#	echo "dest:"
#	pwd
	
	while read line
	do
		fileName=`basename "${line}"`
		find "${destinationFolderPath}" -name "${fileName}" -type f \! \( -newermm "${line}" \) -exec sh -c 'exec echo "`basename "$@"`" > "/tmp/3.txt"' inline {} +
	done < "${temporaryFilePath}"
	
	if [ -f "/tmp/3.txt" ]
	then	
		while read fileName
		do
			if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
				cp -f -pv "${sourceFolderPath}/${fileName}" "${destinationFolderPath}/${fileName}"	
			else
				cp -f -p "${sourceFolderPath}/${fileName}" "${destinationFolderPath}/${fileName}"	
			fi
		done < "/tmp/3.txt"
	else
		echo "info FolderCopyNewerFilesSafe - no files to copy"
	fi
	
	
#	res=$?
	cd "${currentFolderPath}"

	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo
		echo "info FolderCopyNewerFilesSafe - destination folder contents at exit:"
		ls -l "$destinationFolderPath"
	fi
#	return ${res}
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

function ExtractVersion()
{
	local bundleInfoPlistFilePathWithoutExtension=$1
	if [ -z "$bundleInfoPlistFilePathWithoutExtension" ] ; then
		if [ "$DETAIL_LEVEL" -ge "1" ] ; then
			echo "error ExtractVersion: empty path passed!"
			echo "Pass in the first function parameter the full path to bundle property list, without extension."
		fi
		return 1
	fi

	local bundleVersionString="2.01.45"
	local bundleVersionMajor=`echo $bundleVersionString | cut -d. -f1`
	local bundleVersionMinor=`echo $bundleVersionString | cut -d. -f2`
	local bundleVersionBuildNumber=`echo $bundleVersionString | cut -d. -f3`

	printf "%d" $(echo $bundleVersionMajor*10000+$bundleVersionMinor*100+$bundleVersionBuildNumber | bc) 
}

function SetPermissions
{
	local targetBundlePath="$1"

	chown -R root "${targetBundlePath}/"
	if [ $? -ne 0 ]
	then
		  echo "SetPermissions error: cannot set root ownership to \"${targetBundlePath}\"."
		  return 1
	fi

	chgrp -R admin "${targetBundlePath}/" 
	if [ $? -ne 0 ]
	then
		  echo "SetPermissions error: cannot set admin group membership to \"${targetBundlePath}\"."
		  return 1
	fi

	find "${targetBundlePath}" -type f -exec chmod 644 {} \;
	find "${targetBundlePath}" -type d -exec chmod 755 {} \;
	find "${targetBundlePath}/Contents/MacOS" -exec chmod 755 {} \;

	chmod 755 "${targetBundlePath}" 
	if [ $? -ne 0 ]
	then
		  echo "SetPermissions error: cannot set browse and execute permission to \"${targetBundlePath}\"."
		  return 1
	fi
}


DETAIL_LEVEL=2

# check user permissions
MY_UID=`/usr/bin/id -u`
if [ "$MY_UID" != "0" ]
then
	echo
	echo "You should have root privileges in order to install $FULL_SOFTWARE_PRODUCT_NAME."
	echo "Please login as root or use an utility 'su' or 'sudo' when you run $THIS_SCRIPT_PATH." 
	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo "Current UID: $MY_UID."
	fi	
	echo "Installation terminated."	
	exit 2
else
	if [ "$DETAIL_LEVEL" -ge "1"  ] ; then
		echo "root UID: $MY_UID."
	fi		
fi


thisScriptPath=$0
thisScriptName=`basename "${thisScriptPath}"`
thisScriptFolderPath=`dirname "${thisScriptPath}"`
echo "${thisScriptName} info: started in \"${thisScriptFolderPath}\"."

packagePath=$1
packageName=`basename "${packagePath}"`
packageFolderPath=`dirname "${packagePath}"`
echo "${thisScriptName} info: package of origin is \"${packageName}\" in \"${packageFolderPath}\"."

# NOTE that's package project location (most probably Application support/Uninstall), not the product's bundle location !
targetLocationPath=$2
echo "${thisScriptName} info: package target location is \"${targetLocationPath}\"."
targetMountPoint=$3
echo "${thisScriptName} info: target mount point is \"${targetMountPoint}\"."


payloadFolderPath="${packageFolderPath}/Data/Payload"
#echo "${thisScriptName} info: payload folder is \"${payloadFolderPath}\"."
bundleFileName=`ls "${payloadFolderPath}" | grep -v ".DS_Store"`
bundlePath="${payloadFolderPath}/${bundleFileName}"

bundleInfoPlistFilePath="${bundlePath}/Contents/Info.plist"
if [ -f "$bundleInfoPlistFilePath" ]
then
	printf "${thisScriptName} info:  processing \"${bundleInfoPlistFilePath}\"...\n"
else
	printf "${thisScriptName} error:  !!!  the file \"${bundleInfoPlistFilePath}\"  not found !!!\n"
	exit 1
fi

bundleInfoPlistFilePathWithoutExtension="${bundlePath}/Contents/Info"
bundleResourcesFolderPath="${bundlePath}/Contents/Resources"

vendorName="Samsung"
if [ -z "$vendorName" ]
then
	echo "${thisScriptName} error:  The key VendorName not defined in \"${bundleInfoPlistFilePathWithoutExtension}.plist\"\n"
	exit 2
fi
echo "${thisScriptName} info: vendor name is \"${vendorName}\"."

productName="ICDM"
if [ -z "$productName" ]
then
	echo "${thisScriptName} error:  The key ProductName not defined in \"${bundleInfoPlistFilePathWithoutExtension}.plist\"\n"
	exit 2
fi
echo "${thisScriptName} info: product name is \"${productName}\"."

modelName=`defaults read "$bundleInfoPlistFilePathWithoutExtension" ModelName -string`
if [ -z "$modelName" ]
then
	echo "${thisScriptName} warning:  The key ModelName not defined in \"${bundleInfoPlistFilePathWithoutExtension}.plist\"\n"
else
	echo "${thisScriptName} info: model name is \"${modelName}\"."
fi


FULL_SOFTWARE_PRODUCT_NAME="${vendorName} ${productName}"

# print startup date
echo "$FULL_SOFTWARE_PRODUCT_NAME Install - started at `date`"
TIME_BEGIN=`date +%s`

applicationTitle="Samsung Scanner"
applicationTitleFirstLetterLoverCase=`echo ${applicationTitle:0:1} | tr "[A-Z]" "[a-z]"`
applicationTitleCamelCase=`echo $applicationTitle | sed -e "s/ //g" -e "s/^./$applicationTitleFirstLetterLoverCase/g"`

backupFolderName="__Backup_ICC_${applicationTitleCamelCase}__"
backupFolderPath="/tmp/${backupFolderName}"

#FolderRemoveSubset "/tmp" "${backupFolderName}"
# ignore result
FolderReCreate "${backupFolderPath}"
if [ $? -ne 0 ]
then
	  echo "${thisScriptName} error: cannot create backup folder \"${backupFolderPath}\"."
	  exit 1
fi

targetFolderPath="/Library/Image Capture/Devices"
# echo -e "${thisScriptName} info: target folder is \"${targetFolderPath}\"."
targetBundlePath="${targetFolderPath}/${bundleFileName}"
#targetBundlePath="${targetFolderPath}/${applicationTitle}.app"
targetResourcesFolderPath="${targetBundlePath}/Contents/Resources"
#echo "${thisScriptName} info: target folder is \"${targetFolderPath}\"."

bundleVersionSum=`ExtractVersion "$bundleInfoPlistFilePathWithoutExtension"`


doIccBackup="1"
doBundleCopy=0
doIccCopy=0
doIccRestore=0

if [ -d "${targetBundlePath}" ]
then
	targetBundleInfoPlistFilePathWithoutExtension="${targetBundlePath}/Contents/Info"

	echo "${thisScriptName} info: \"$bundleFileName\" is already installed. Upgrading..."
	
	if [ "$doIccBackup" -eq "1" ]
	then		
		echo "${thisScriptName} info:  creating backup directory $backupFolderPath:"
#		mkdir -pv "$backupFolderPath"


		echo "${thisScriptName} info: backing up ICC from \"${targetResourcesFolderPath}\" to \"${backupFolderPath}\"..."

		FolderCopyFilesSafe "${targetResourcesFolderPath}" "${backupFolderPath}" "*.icc"
		if [ $? -ne 0 ]
		then
			  echo "${thisScriptName} error: cannot copy \"*.icc\" from \"${targetResourcesFolderPath}\" to \"${backupFolderPath}\"."
			  exit 1
		fi
		doIccRestore=1
	else
		echo "${thisScriptName} info: no need to backup ICC files."
		doIccRestore=0
	fi

#	if [ "$doVersionCheck" -eq "1" ]

	targetBundleVersionSum=`ExtractVersion "$targetBundleInfoPlistFilePathWithoutExtension"`
	
	echo "bundleVersionSum: $bundleVersionSum, targetBundleVersionSum: $targetBundleVersionSum"
	if [ "${bundleVersionSum}" -le "${targetBundleVersionSum}" ]
	then
		echo "${thisScriptName} warning: \"$bundleFileName\" of current or newer version is already installed. Skip updating binaries, copy ICC only."
		doBundleCopy=0
		doIccCopy=1
		doIccRestore=0
	else
		echo "Removing old product \"${bundleFileName}\" from \"${targetFolderPath}\"..."

		FolderRemoveSubset "${targetFolderPath}" "${bundleFileName}"
		if [ $? -ne 0 ]
		then
			  echo "${thisScriptName} error: cannot remove \"${bundleFileName}\" from \"${targetFolderPath}\"."
			  exit 1
		fi
		doBundleCopy=1
	fi

else
	echo "${thisScriptName} info: \"$bundleFileName\" not found on disk, installing..."	
	doBundleCopy=1
fi

# copy the uninstaller
uninstallFolderPath="${packageFolderPath}/Data/Uninstall"
uninstallTargetFolderPath="/Library/Application Support/Samsung/Uninstaller/Common"
uninstallerFileName="${productName}.sh"

echo "uninstallFolderPath: $uninstallFolderPath, uninstallTargetFolderPath: $uninstallTargetFolderPath, uninstallerFileName: $uninstallerFileName."

mkdir -pv "${uninstallTargetFolderPath}"
if [ $? -ne 0 ]
then
	  echo "${thisScriptName} error: cannot create uninstall folder \"${uninstallTargetFolderPath}\"."
	  exit 1
fi

# FolderCopySubset 
FolderCopyFilesSafe "${uninstallFolderPath}" "${uninstallTargetFolderPath}" "${uninstallerFileName}"
if [ $? -ne 0 ]
then
	  echo "${thisScriptName} error: cannot copy old \"${uninstallerFileName}\" from \"${uninstallFolderPath}\" to \"${uninstallTargetFolderPath}\"."
	  exit 1
fi

FolderCopyNewerFilesSafe "${uninstallFolderPath}" "${uninstallTargetFolderPath}" "${uninstallerFileName}"
if [ $? -ne 0 ]
then
	  echo "${thisScriptName} error: cannot copy new \"${uninstallerFileName}\" from \"${uninstallFolderPath}\" to \"${uninstallTargetFolderPath}\"."
	  exit 1
fi

# set uninstaller ownership
find "${uninstallTargetFolderPath}" -name "${uninstallerFileName}" -exec chown -R root:admin {} \;
resultCode="$?"
if [ "$resultCode" -ne 0 ]
then
	echo "${thisScriptName} error: cannot set ownership to ${uninstallerFileName}. Installation terminated."
	exit 1
fi

# set ICC permissions
find "${uninstallTargetFolderPath}" -name "${uninstallerFileName}" -exec chmod 0755 {} \;
resultCode="$?"
if [ "$resultCode" -ne 0 ]
then
	echo "${thisScriptName} info: cannot permissions to ${uninstallerFileName}. Installation terminated."
	exit 1
fi


# copy the bundle
if [ "$doBundleCopy" -eq "1" ]
then
	FolderCopySubset "${payloadFolderPath}" "${targetFolderPath}" "${bundleFileName}"
	if [ $? -ne 0 ]
	then
		  echo "${thisScriptName} error: cannot copy \"${bundleFileName}\" from \"${payloadFolderPath}\" to \"${targetFolderPath}\"."
		  exit 1
	fi
fi

# copy ICC files
if [ "$doIccCopy" -eq "1" ]
then
	FolderCopyFilesSafe "${bundleResourcesFolderPath}" "${targetResourcesFolderPath}" "*.icc"
	if [ $? -ne 0 ]
	then
		  echo "${thisScriptName} error: cannot copy \"*.icc\" from \"${bundleResourcesFolderPath}\" to \"${targetResourcesFolderPath}\"."
		  exit 1
	fi
	
#	FolderCopyNewerFilesSafe "${bundleResourcesFolderPath}" "${targetResourcesFolderPath}" "*.icc"
#	if [ $? -ne 0 ]
#	then
#		  echo "${thisScriptName} error: cannot copy newer \"*.icc\" from \"${bundleResourcesFolderPath}\" to \"${targetResourcesFolderPath}\"."
#		  exit 1
#	fi
fi


# set bundle permissions
SetPermissions "${targetBundlePath}"
if [ $? -ne 0 ]
then
	  echo "${thisScriptName} error: cannot set permissions to \"${targetBundlePath}\". Installation terminated."
	  exit 1
fi

# restore ICC files
if [ "$doIccRestore" -eq "1" ]
then
	echo "${thisScriptName} info: restoring saved icc from \"${backupFolderPath}\" to \"${targetResourcesFolderPath}\"..."
	FolderCopyFilesSafe "${backupFolderPath}" "${targetResourcesFolderPath}" "*.icc"
	#ignore result
	
	FolderCopyNewerFilesSafe "${backupFolderPath}" "${targetResourcesFolderPath}" "*.icc"
	#ignore result
	
else
	echo "${thisScriptName} info: no need to restore ICC files."
fi


# set ICC ownership
find "${targetResourcesFolderPath}" -name "*.icc" -exec chown -R root:admin {} \;
resultCode="$?"
if [ "$resultCode" -ne 0 ]
then
	echo "${thisScriptName} error: cannot set ownership to ICC files. Installation terminated."
	exit 1
fi

# set ICC permissions
find "${targetResourcesFolderPath}" -name "*.icc" -exec chmod 0664 {} \;
resultCode="$?"
if [ "$resultCode" -ne 0 ]
then
	echo "${thisScriptName} info: cannot permissions to ICC files. Installation terminated."
	exit 1
fi


# optionally install the USD agent
usdAgentArchiveFolderPath=${packageFolderPath}/Data/Discovery
usdAgentArchiveFileName=USDAgent.zip
usdAgentArchiveFilePath=${usdAgentArchiveFolderPath}/${usdAgentArchiveFileName}

if [ -f "${usdAgentArchiveFilePath}" ]
then
	echo "usdAgentArchiveFilePath \"${usdAgentArchiveFilePath}\" found."

	if [ -z "$modelName" ]
	then
		echo "${thisScriptName} error:  The key ModelName missing in \"${bundleInfoPlistFilePathWithoutExtension}.plist\"\n"
		exit 2
	fi

	usdAgentTargetFolderPath="/Library/Application Support/${vendorName}/TWAIN Discovery"
	mkdir -pv "${usdAgentTargetFolderPath}"
	if [ $? -ne 0 ]
	then
		echo "${thisScriptName} error: cannot create agent folder \"${usdAgentTargetFolderPath}\"."
		exit 1
	fi

	echo "extracting usdAgentArchiveFilePath \"$usdAgentArchiveFilePath\" to usdAgentTargetFolderPath \"$usdAgentTargetFolderPath\"."
	unzip -d "${usdAgentTargetFolderPath}" "${usdAgentArchiveFilePath}"
	if [ $? -ne 0 ]
	then
		echo "${thisScriptName} error: cannot extract agent bundle."
		exit 1
	fi


	usdAgentFinalFolderPath="${usdAgentTargetFolderPath}/${modelName}"
	usdAgentBundlePath="${usdAgentFinalFolderPath}/Select Scanner.app"
	usdAgentBundleInfoPlistFilePathWithoutExtension="${usdAgentBundlePath}/Contents/Info"	
	
	if [ -d "${usdAgentBundlePath}" ]
	then
		distributivePlistFilePathWithoutExtension="${usdAgentTargetFolderPath}/USDAgent/Select Scanner.app/Contents/Info"
		
		usdAgentBundleVersionSum=`ExtractVersion "$usdAgentBundleInfoPlistFilePathWithoutExtension"`
		distributiveBundleVersionSum=`ExtractVersion "$distributivePlistFilePathWithoutExtension"`
		
		echo "usdAgentBundleVersionSum: $usdAgentBundleVersionSum, distributiveBundleVersionSum: $distributiveBundleVersionSum"
		if [ "${distributiveBundleVersionSum}" -le "${usdAgentBundleVersionSum}" ]
		then
			echo "${thisScriptName} warning: TWAIN Discovery agent of current or newer version is already installed."
			doAgentCopy=0
		else
			echo "${thisScriptName} warning: TWAIN Discovery agent of older version is already installed, upgrading..."
			doAgentCopy=1
		fi
	else
		echo "${thisScriptName} info: TWAIN Discovery agent not found on disk, installing..."	
		doAgentCopy=1
	fi	
	
	if [ "$doAgentCopy" -eq "1" ]
	then
		rm -rvf "${usdAgentFinalFolderPath}"
		mv -fv "${usdAgentTargetFolderPath}/USDAgent" "${usdAgentFinalFolderPath}" 
		if [ $? -ne 0 ]
		then
			echo "${thisScriptName} error: cannot rename agent folder."
			exit 1
		fi
		
		usdAgentOptFileName=USDAgentOpt.plist
		usdAgentOptFilePath=${usdAgentArchiveFolderPath}/${usdAgentOptFileName}
		if [ -f "${usdAgentOptFilePath}" ]
		then
			cp -fv "${usdAgentOptFilePath}" "${usdAgentBundlePath}/Contents/Resources"
			if [ $? -ne 0 ]
			then
				echo "${thisScriptName} warning: cannot copy agent options!"
			fi
		else
			echo "${thisScriptName} warning: agent options missing!"
		fi	

		SetPermissions "${usdAgentBundlePath}"
		if [ $? -ne 0 ]
		then
			echo "${thisScriptName} error: cannot set permissions to \"${usdAgentBundlePath}\". Installation terminated."
			exit 1
		fi
	else
		rm -rvf "${usdAgentTargetFolderPath}/USDAgent"
	fi
	
else
	echo "usdAgentArchiveFilePath \"${usdAgentArchiveFilePath}\" not found."
fi


# print finish date
TIME_END=`date +%s`
echo
ElapsedTimePrint "$FULL_SOFTWARE_PRODUCT_NAME Install - finished at `date`. Processing time:" $TIME_BEGIN $TIME_END

