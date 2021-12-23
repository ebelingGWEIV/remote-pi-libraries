# Create the directory for storing the compilation tools
CURRENT_DIR=$(pwd)
TOOLCHAIN_SCRIPTS=$CURRENT_DIR/toolchain-scripts

echo "This script can be rerun, to complete any failed tasks. \nCompleted tasks will be skipped."

#Check if an argument was given and if the path is valid
if [ $(wc -l < $1) > 0  && -d "$1"]
then
    BASE_DIR=$1
else 
    echo "No path as given, the current directory will be used $(pwd)"
    BASE_DIR=$CURRENT_DIR
fi

if [ -d "$BASE_DIR" ]
then
    echo "$BASE_DIR already exists"
else
    echo "creating $BASE_DIR"
    sudo mkdir $BASE_DIR
fi

echo "updating permissions for $BASE_DIR"
sudo chown $(whoami) $BASE_DIR
cd $BASE_DIR

# Get the pi tools
PI_TOOLS=$BASE_DIR/tools
if [ -d "$PI_TOOLS" ]
then
    echo "$PI_TOOLS already exist"
else
    echo "getting pi tools"
    git clone https://github.com/raspberrypi/tools
fi

# Get wiring pi
WIRING_PI=$BASE_DIR/WiringPi
if [ -d "$WIRING_PI" ]
then
    echo "$WIRING_PI already exists"
else
    echo "getting wiring pi"
    git clone https://github.com/WiringPi/WiringPi.git
fi

# Add the cmake file for wiring pi
WIRING_CMAKE=$WIRING_PI/wiringPi/CMakeLists.txt
WIRING_TOOLCHAIN=$WIRING_PI/wiringPi/Toolchain-rpi.cmake
if [ -f "$WIRING_CMAKE" ]
then
    echo "CMakeLists.txt for cross compiling wiring pi already exists"
    echo "Note: If you wish to rebuild, delete all CMake files and directories within $WIRING_PI/wiringPi before running this again"
else
    echo "Creating CMakeLists.txt for cross compiling wiring pi"


    # Copy and rename over the wiring-pi cmake script
    cp $TOOLCHAIN_SCRIPTS/wiring-pi.cmake $WIRING_CMAKE

    # Finally, copy and rename the toolchain script
    cp $TOOLCHAIN_SCRIPTS/toolchain-cmake $WIRING_TOOLCHAIN

    echo "Building the Wiring Pi library"
    # Move directories to make these commands a bit simpler
    cd $WIRING_PI/wiringPi
    cmake . -DCMAKE_TOOLCHAIN_FILE=Toolchain-rpi.cmake
    make

    echo "Please manually verify that there are no warnings other than pointer size warnings"
fi
# Return to the base directory
cd $BASE_DIR