#!/bin/bash

set -e
set -u

CURDIR="$(pwd)"
DEPSDIR="deps"
CURUSER=$USER

if [ ! -d "$DEPSDIR" ]; then
    if [[ $UID != 0 ]]; then
        echo "This seems like the first run. Some dependencies will be installed automatically but requires root privileges."
        sudo echo "ok"        
    fi
    
    rm -rf tmp_deps
    mkdir tmp_deps

    wget https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz -O tmp_deps/arduino.tar.xz
    tar xf tmp_deps/arduino.tar.xz -C tmp_deps
    mv tmp_deps/arduino-* tmp_deps/arduino
    rm tmp_deps/arduino.tar.xz

    mkdir -p tmp_deps/arduino/hardware/espressif/
    wget https://github.com/espressif/arduino-esp32/archive/master.zip -O tmp_deps/arduino/hardware/espressif/master.zip
    unzip tmp_deps/arduino/hardware/espressif/master.zip -d tmp_deps/arduino/hardware/espressif/
    mv tmp_deps/arduino/hardware/espressif/arduino-esp32-master tmp_deps/arduino/hardware/espressif/esp32

    cd tmp_deps
    sudo usermod -a -G dialout $CURUSER
    wget https://bootstrap.pypa.io/get-pip.py
    sudo python get-pip.py
    sudo pip install pyserial

    cd arduino/hardware/espressif/esp32/tools
    python get.py

    cd $CURDIR

    rm -rf tmp_deps/arduino/libraries/RobotIRremote


    mv tmp_deps deps
fi

while read p; do
    SANITIZED=$(echo $p | sed -e 's/[^0-9a-zA-Z]/-/g')
    TARGETFILE="deps/arduino/libraries/$SANITIZED"
    if [ ! -e "$TARGETFILE" ]; then
        wget $p -O "$TARGETFILE"
        unzip "$TARGETFILE" -d deps/arduino/libraries/
    fi
done <libs.txt

deps/arduino/hardware/espressif/esp32/tools/build.py --ide_path="$CURDIR/deps/arduino" \
    -v -d "$CURDIR/deps/arduino/hardware/" -l "$CURDIR/deps/arduino/libraries/" \
    -o app.bin -b nodemcu-32s $1

deps/arduino/hardware/espressif/esp32/tools/esptool.py write_flash 0x10000 app.bin
screen /dev/ttyUSB0 115200
