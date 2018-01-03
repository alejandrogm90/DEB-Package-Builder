#!/bin/bash

#VARIABLES
accion=0

function error1 () {
    echo ''
    echo ' [ARGUMENT] [VARIABLE]'
    echo ' ALL ARGUMENTS'
    echo ' -h o --help              Help.'
    echo ' -cr o --create           Create a new project.'
    echo ' -co o --codificate       Codificate a project as ".deb"'
    echo ''
}

if [ $1 == '-h' ] || [ $1 == '--help' ] ; then error1 ; exit 1 ; fi
if [ $# -ne 2 ] ; then echo 'Input error.' ; error1 ; exit 2 ; fi
if [ -f $2 ] ; then echo 'The file "'$2'" already exist.' ; exit 3 ; fi

if [ $1 == "-cr" ] || [ $1 == "--create" ] ; then accion=1 ; fi
if [ $1 == "-co" ] || [ $1 == "--codificate" ] ; then accion=2 ; fi

case $accion in
    1)
        mkdir $2
        mkdir -p $2/usr/share/miPythonApp
        echo '' >> $2/usr/share/miPythonApp/launch.py
        # CONTROL FILE
        mkdir $2/DEBIAN
        cat > $2/DEBIAN/control << __EOF__
Source: $2
Package: $2
Priority: optional
Section: misc
Maintainer: your_name <your_mail@mail.com>
Homepage: http://www.your-webside.com/
Architecture: all
Version: 1.0
Pre-Depends: pyton3
Origin: your_origin
Description: descripcion
 Long descripcion .

__EOF__
        # BEFORE INSTALLATION - FILE
        cat > $2/DEBIAN/preinst << __EOF__
#! /bin/bash -e
__EOF__
        # AFTER INSTALLATION - FILE
        cat > $2/DEBIAN/postinst << __EOF__
#! /bin/bash -e
ln -fs "/usr/share/miPythonApp/launch.py" "/usr/bin/miPythonApp"
update-mime-database /usr/share/mime
__EOF__
        # BEFORE REMOVE - FILE
	cat > $2/DEBIAN/prerm << __EOF__
#! /bin/bash -e
rm -R "/usr/bin/miPythonApp"
__EOF__
        # AFTER REMOVE - FILE
	cat > $2/DEBIAN/postrm << __EOF__
#! /bin/bash -e
update-mime-database /usr/share/mime
__EOF__
    ;;
    2)
        sudo chown -R root:root $2
        if [ -f $2/DEBIAN/preinst ] ; then sudo chmod 555 $2/DEBIAN/postinst ; fi
        if [ -f $2/DEBIAN/postinst ] ; then sudo chmod 555 $2/DEBIAN/postinst ; fi
        if [ -f $2/DEBIAN/prerm ] ; then sudo chmod 555 $2/DEBIAN/prerm ; fi
        if [ -f $2/DEBIAN/postrm ] ; then sudo chmod 555 $2/DEBIAN/postrm ; fi
        dpkg -b $2 "$2".deb
        sudo rm -R $2
    ;;
    *)
        error1
        exit 4
    ;;
esac
