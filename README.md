# arduino-esp32-cli-bootstrap
Bootstrap, Build and Flash an Arduino ESP32 project from the commandline 

## Bootstrap your project
Copy `arduino-esp32-cli-bootstrap.sh`inside your project directory. 
Run it and supply your Arduino sketch file as first argument:

    ./arduino-esp32-cli-bootstrap.sh test.ino

The script downloads and installs Arduino, the arduino-esp32 libs and any 3rd-party Arduino-Library which
is defined in an libs.txt located next to the script file.

