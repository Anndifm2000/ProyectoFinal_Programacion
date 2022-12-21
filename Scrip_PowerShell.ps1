[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
$global:Nombre=""
$global:Password=""
$global:Login=""

function conexion{
    param(
        [String[]]$Query

    )

    $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $ConnectionString = "server=" + "localhost" + ";port=3306;uid=" + "root" + ";pwd=1234" + ";database="+"usuarios"
    $Connection.ConnectionString = $ConnectionString
    $Connection.Open()
 
    $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
    $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
    $DataSet = New-Object System.Data.DataSet
    $RecordCount = $dataAdapter.Fill($dataSet, "data")
    if($global:Login -eq "Login"){
        $global:Nombre = $DataSet.Tables[0].Nombre
        $global:Password = $DataSet.Tables[0].Password
        $global:Login = ""
    }
    
    $Connection.Close()
}

function Ob-Cre {
    param(
        [String[]]$Usuario,
        [String[]]$Contraseña
    )
    $global:Login="Login"
    conexion -Query "Select * from usuario where Nombre = '$Usuario' "

    
    if($Contraseña -eq $Password) {
        Set-Content -Path Z:\Salida.txt -Value "Sesion iniciada correctamente $global:Nombre" 
        limpiar
    }else {
        $global:Nombre =""
        $global:Password =""
        Set-Content -Path Z:\Salida.txt -Value "Usuario Invalido o Contraseña Incorrecta"        
    }

    

}

function Agregar {
    param(
        [String[]]$Usuario,
        [String[]]$Contraseña
    )
    New-Item -ItemType Directory -Name "$Usuario" -Path Z:\ 
    conexion -Query "Insert into Usuario values ('$Usuario','$Contraseña')"
    conexion -Query "Insert into directorios values ('$Usuario','Z:\\$Usuario')"
    Set-Content -Path Z:\Salida.txt -Value "Usuario creado exitosamente"
    limpiar
}

function Eliminar {
    param(
        [String[]]$Usuario
    )

    conexion -Query "DELETE FROM Usuario WHERE Nombre='$Usuario'"
    conexion -Query "DELETE FROM directorios WHERE Usuario='$Usuario'"
    Remove-Item -Path "Z:\$Usuario"
    salida -Mensaje "$Usuario Eliminado"    
}

function Modificar {
    param(
        [String[]]$Usuario,
        [String[]]$Usuario2,
        [String[]]$Contraseña2          
    )

    conexion -Query "UPDATE Usuario SET Nombre = '$Usuario2', Password = '$Contraseña2' WHERE Nombre = '$Usuario'"
    conexion -Query "UPDATE directorios SET Usuario = '$Usuario2', Directorio = 'Z:\\$Usuario2' WHERE Usuario = '$Usuario'"
    
    Rename-Item -Path "Z:\$Usuario" -NewName "$Usuario2"
    
}

function limpiar {
    Set-Content Z:\Console.txt -Value "Powershell:Prompt:"
}

function salida {
    param(
        [String[]]$Mensaje        
    )
    Set-Content Z:\Salida.txt -Value "$Mensaje" 
}

function admin {
    param(
        [String[]]$Ejecutar        
    )

    if($global:Nombre -eq "Josa"){
            Switch -Wildcard ("$Ejecutar"){
                "Agregar*" {
                    $User=$Ejecutar.Split(' ')[1]
                    $Contra=$Ejecutar.Split(' ')[2]
                    Agregar -Usuario $User -Contraseña $Contra
                }
                "Eliminar*" {
                    $User=$Ejecutar.Split(' ')[1]
                    Salida -Mensaje "Eliminando Usuario $User"
                    Eliminar -Usuario $User
                    limpiar
                }
                "Modificar*" {
                    $User=$Ejecutar.Split(' ')[1]
                    $User2=$Ejecutar.Split(' ')[2]
                    $Contra=$Ejecutar.Split(' ')[3]
                    Modificar -Usuario $User -Usuario2 $User2 -Contraseña2 $Contra
                }
            }
    }else {
            Switch -Wildcard ("$Ejecutar"){
            "Login*"{
                $User=$Ejecutar.Split(' ')[1]
                $Contra=$Ejecutar.Split(' ')[2]
                Ob-Cre -Usuario $User -Contraseña $Contra
            }
            "Exit*"{
                Salida -Mensaje "Sesion $global:Nombre Cerrada"
                $global:Nombre=""
                $global:Password=""
                limpiar
            }
            "Subir*" {
                $Archivo=$Ejecutar.Split(' ')[1]
                salida -Mensaje "Moviendo archivo $Archivo a carpeta personal"
                Move-Item -Path Z:\$Archivo -Destination Z:\$global:Nombre
                limpiar
            }
            "Listar"{
                $result = Get-Process -IncludeUserName | Where-Object UserName -EQ "DESKTOP-NUC4H85\$global:Nombre"
                Set-Content Z:\Salida.txt -Value $result.Name
            }
            "Detener"{
                salida -Mensaje "Deteniendo los procesos del Usuario $global:Nombre"
                $Process = Get-Process -IncludeUserName |  Where-Object UserName -EQ "DESKTOP-NUC4H85\$global:Nombre" | Select-Object -Property Id
                Stop-Process -Id $Process
            }
            "Files*"{
                $resul = Dir Z:\$global:Nombre
                salida -Mensaje "$resul"
                limpiar
           }
          }
    }
          
}

while(1){
        $Comando = Get-Content Z:\Console.txt
        $Prompt=$Comando.Split(":")[0] 
        $Run=$Comando.Split(":")[2]
    if($Prompt -eq "Powershell"){
        Write-Host "$Run"
        admin -Ejecutar $Run
        Get-Content -Path Z:\Salida.txt
        sleep 3
        cls
    }
}
    
    
    
    
    
    
