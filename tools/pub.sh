#!/bin/bash

echo '### status_bar'

cd ./status_bar
flutter pub upgrade
cd $OLDPWD

echo '### status_bar_linux'

cd ./status_bar_linux
flutter pub upgrade
cd $OLDPWD

echo '### status_bar_macos'

cd ./status_bar_macos
flutter pub upgrade
cd $OLDPWD

echo '### status_bar_platform_interface'

cd ./status_bar_platform_interface
flutter pub upgrade
cd $OLDPWD

echo '### status_bar_windows'

cd ./status_bar_windows
flutter pub upgrade
cd $OLDPWD

echo '### status_bar/example'

cd ./status_bar/example
flutter pub upgrade
cd $OLDPWD

echo '### all done'
