#!/bin/bash

#VARIABLES
accion=0

function error1 () {
    echo ''
    echo ' [ARGUMENTO] [VARIABLES]'
    echo ' ARGUMENTOS '
    echo ' -h o --help              Ayuda.'
    echo ' -cr o --crear            Crea un paquete con un nombre dedo como variable.'
    echo ' -co o --codificar        Codifica un paquete con un nombre dedo como variable.'
    echo ''
}

if [ $1 == '-h' ] || [ $1 == '--help' ] ; then
    error1
    exit 1
fi

if [ $# -ne 2 ] ; then
    echo 'El número de parámetros introducidos es erroneo.'
    error1
    exit 2
fi

if [ -f $2 ] ; then
    echo 'El fichero "'$2'" ya existe.'
    exit 3
fi   

if [ $1 == "-cr" ] || [ $1 == "--crear" ] ; then
    accion=1
fi
if [ $1 == "-co" ] || [ $1 == "--codificar" ] ; then
    accion=2
fi

case $accion in
    1)
        mkdir $2
        mkdir -p $2/usr/share/miPythonApp
        echo '' >> $2/usr/share/miPythonApp/launch.py
        # CREANDO EL FICHERO DE CONTROL
        mkdir $2/DEBIAN
        cat > $2/DEBIAN/control << __EOF__
Source: $2
Package: $2
Priority: optional
Section: misc
Maintainer: Alejandro Gomez <alejandrogomezmartin90@gmail.com>
Homepage: http://www.uldum-freeiz.com/
Architecture: all
Version: 1.0
Depends:
Description: descripcion
 Programas que son muy necesarios.
__EOF__
        # CREANDO EL FICHERO postinst
        cat > $2/DEBIAN/postinst << __EOF__
#! /bin/bash -e
ln -fs "/usr/share/miPythonApp/launch.py" "/usr/bin/miPythonApp"
update-mime-database /usr/share/mime
__EOF__
        # CREANDO EL FICHERO prerm
	cat > $2/DEBIAN/prerm << __EOF__
#! /bin/bash -e
rm "/usr/bin/miPythonApp"
__EOF__
        # CREANDO EL FICHERO postrm
	cat > $2/DEBIAN/postrm << __EOF__
#! /bin/bash -e
update-mime-database /usr/share/mime
__EOF__
    ;;
    2)
        sudo chown -R root:root $2
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
