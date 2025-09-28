#!/bin/bash
##setup command=wget -q "--no-check-certificate" https://raw.githubusercontent.com/Ham-ahmed/pro/refs/heads/main/MagicPanelpro_install.sh -O - | /bin/sh

######### Only This line to edit with new version ######
version='6.1'
##############################################################

TMPPATH=/tmp/MagicPanel
GITHUB_RAW="https://raw.githubusercontent.com/Ham-ahmed/pro/refs/heads/main"

if [ ! -d /usr/lib64 ]; then
    PLUGINPATH=/usr/lib/enigma2/python/Plugins/Extensions/MagicPanelPro
else
    PLUGINPATH=/usr/lib64/enigma2/python/Plugins/Extensions/MagicPanelPro
fi

# دالة للتحقق من التحديثات الجديدة
check_for_updates() {
    echo "> Checking for updates..."
    LATEST_VERSION=$(wget -q -O - "$GITHUB_RAW/version.txt" 2>/dev/null | head -n 1 | tr -d '\r' | tr -d ' ')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "> Could not check for updates. Continuing installation..."
        return 1
    fi
    
    if [ "$version" != "$LATEST_VERSION" ]; then
        echo ""
        echo "#########################################################"
        echo "#                  NEW VERSION AVAILABLE                #"
        echo "#                  Current version: $version                  #"
        echo "#                  Latest version: $LATEST_VERSION                  #"
        echo "#        Please download the latest version from:       #"
        echo "#    https://github.com/Ham-ahmed/pro/main         #"
        echo "#########################################################"
        echo ""
        echo "> Press Ctrl+C to cancel and download the latest version"
        echo "> Continuing with current version in 10 seconds..."
        sleep 10
        return 0
    else
        echo "> You have the latest version ($version)"
        return 1
    fi
}

# check depends packges
if [ -f /var/lib/dpkg/status ]; then
    STATUS=/var/lib/dpkg/status
    OSTYPE=DreamOs
else
    STATUS=/var/lib/opkg/status
    OSTYPE=Dream
fi

echo ""
if python --version 2>&1 | grep -q '^Python 3\.'; then
    echo "You have Python3 image"
    PYTHON=PY3
    Packagesix=python3-six
    Packagerequests=python3-requests
else
    echo "You have Python2 image"
    PYTHON=PY2
    Packagerequests=python-requests
fi

if [ $PYTHON = "PY3" ]; then
    if grep -qs "Package: $Packagesix" $STATUS ; then
        echo ""
    else
        opkg update && opkg install python3-six
    fi
fi

echo ""
if grep -qs "Package: $Packagerequests" $STATUS ; then
    echo ""
else
    echo "Need to install $Packagerequests"
    echo ""
    if [ $OSTYPE = "DreamOs" ]; then
        apt-get update && apt-get install python-requests -y
    elif [ $PYTHON = "PY3" ]; then
        opkg update && opkg install python3-requests
    elif [ $PYTHON = "PY2" ]; then
        opkg update && opkg install python-requests
    fi
fi
echo ""

# التحقق من التحديثات قبل المتابعة
check_for_updates

## Remove tmp directory
[ -r $TMPPATH ] && rm -f $TMPPATH > /dev/null 2>&1

## Remove old plugin directory
[ -r $PLUGINPATH ] && rm -rf $PLUGINPATH

# Download and install plugin
# check depends packges
mkdir -p $TMPPATH
cd $TMPPATH
set -e
if [ -f /var/lib/dpkg/status ]; then
    echo "# Your image is OE2.5/2.6 #"
    echo ""
    echo ""
else
    echo "# Your image is OE2.0 #"
    echo ""
    echo ""
fi

wget https://raw.githubusercontent.com/Ham-ahmed/pro/refs/heads/main/MagicPanelpro_v6.1-main.tar.gz
if [ $? -ne 0 ]; then
    echo "Download failed!"
    exit 1
fi

tar -xzf MagicPanel_v6-main.tar.gz
if [ $? -ne 0 ]; then
    echo "Extraction failed!"
    exit 1
fi

cp -r 'MagicPanel-main/usr' '/'
set +e
cd
sleep 2

### Check if plugin installed correctly
if [ ! -d $PLUGINPATH ]; then
    echo "Some thing wrong .. Plugin not installed"
    exit 1
fi

rm -rf $TMPPATH > /dev/null 2>&1
sync
echo ""
echo ""
echo "==================================================================="
echo "===                    INSTALLED SUCCESSFULLY                   ==="
echo "===                        MagicPanel v$version                 ==="
echo "===                Enigma2 restart is required                  ==="
echo "===              UPLOADED BY  >>>>   HAMDY_AHMED                ==="
echo "==================================================================="
sleep 2
echo "==================================================================="
echo "===                        Restarting                           ==="
echo "==================================================================="
sleep 5
killall -9 enigma2
exit 0