#!/bin/bash

echo '### status_bar'

cd ./status_bar
flutter pub outdated
cd $OLDPWD

echo '### status_bar_linux'

cd ./status_bar_linux
flutter pub outdated
cd $OLDPWD

echo '### status_bar_macos'

cd ./status_bar_macos
flutter pub outdated
cd $OLDPWD

echo '### status_bar_platform_interface'

cd ./status_bar_platform_interface
flutter pub outdated
cd $OLDPWD


echo '### status_bar_windows'

cd ./status_bar_windows
flutter pub outdated
cd $OLDPWD

echo '### all done'
