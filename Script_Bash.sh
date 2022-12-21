#!/bin/bash
nombre=""
password=""

consultar (){ 
	cre=$(mysql -u root -p1234 Usuarios -e "select * from Usuario where Nombre = '$1'")
	nombre=$(echo $cre | cut -d' ' -f3)
	password=$(echo $cre | cut -d' ' -f4)
	echo "Nombre de usuario: $nombre"
	echo "Contraseña del usuario: $password"
	if [[ "$password" -eq "$2" ]]
	then
		echo "Usuario logueado correctamente" >  /samba/Salida.txt
	fi
}

agregar (){
	mysql -u root -p1234 Usuarios -e "Insert into Usuario values ('$1','$2')"
	mysql -u root -p1234 Usuarios -e "Insert into directorios values ('$1','/samba/$1') "
	mkdir "/samba/$1"
	echo "Usuario $1 agregado correctamente" > /samba/Salida.txt
}

eliminar (){
	mysql -u root -p1234 Usuarios -e "Delete * from Usuario where Nombre = '$1'"
	mysql -u root -p1234 directorios -e "Delete * from directorios where usuario = '$1'"
	rm -r "/samba/$1"
	echo "Usuario $1 eliminado correctamente" > /samba/Salida.txt
}

modificar (){
	mysql -u root -p1234 Usuarios -e "Update Usuario set Nombre = '$2', password = '$3' where Nombre = '$1'"
	mysql -u root -p1234 Usuarios -e "Update directorios set usuario = '$2', directorio = '/samba/$2' where usuario = '$1'"
	cp "/samba/$1" "/samba/$2"
	rm -r "/samba$1"
	echo "Usuario $1 actualizado" > /samba/Salida.txt
}

limpiar (){
	echo "Bash:Prompt:" > /samba/Console.txt
	echo "Esperando nuevo comando" > /samba/Salida.txt
}

subir (){
	mv "/samba/$1" "/samba/$nombre"
	echo "El archivo $1 ya se encuentra en el directorio personal" > /samba/salida.txt
}

admin (){
	ejecutar=$(echo "$1" | cut -d' ' -f1)
	case "$ejecutar" in
	"Login")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		contra=$(echo "$1" | cut -d' ' -f3)
		consultar "$user" "$contra"
		limpiar
	;;
	"Agregar")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		contra=$(echo "$1" | cut -d' ' -f3)
		agregar "$user" "$contra"
		limpiar 
	;;
	"Eliminar")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		eliminar "$user"
		limpiar
	;;
	"Modificar")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		user2=$(echo "$1" | cut -d' ' -f3)
		contra=$(echo "$1" | cut -d' ' -f4)
		modificar "$user" "$user2" "$contra"
 		limpiar
	;;
	"Listar")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		$(./procesos.sh "$user")
		echo procesos.txt > /samba/Salida.txt
		limpiar
	;;
	"Detener")
		echo "$1"
		user=$(echo "$1" | cut -d' ' -f2)
		pkill -u "$user"
		limpiar
	;;
	"Subir")
		echo "$1"
		archivo=$(echo "$1" | cut -d' ' -f2)
		subir "$archivo"
		limpiar
	;;
	"Files")
		echo "$1"
		direc=$(echo "$1" | cut -d' ' -f2
		ls "/samba/$direc"
	;;
	esac
}

#conexión de Samba
while(true)
do

	comando=$(cat /samba/Console.txt)
	salida=$(cat /samba/Salida.txt)
	prompt=$(echo "$comando" | cut -d ':' -f1)
	if [[ "$prompt" == "Bash" ]]
	then
	sleep 3
	clear
	echo "$salida"
	run=$(echo "$comando" | cut -d':' -f3 )
	admin "$run"
	fi
done
