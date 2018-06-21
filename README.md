# containersBck

- Script para respaldo de contenedores Docker.
  - incluye la opción de respaldar tambien los volumenes enlazados al contenedor.


## Modo de uso
- Editar, si es necesario, las variables del script:
  ```
  bckDir="/backups"
  # Ver 'man date' para consultar el formato de los modificadores de fecha
  bckRetention="10 days ago"
  ```
  - **bckDir**: Directorio donde almacenar los backups
  - **bckRetention**: Periodo de retención


- Ejecutar: ```containerBck.sh -n nombreContenedor [-a|-v "/vol1 /vol2"]```
  - `-a`: Backup de todos los volumnes del contenedor.
  - `-v`: Backup de los volumenes indicados entre las comillas.



### Ejemplo de uso:

 - Backup del contenedor `dokuwiki_pro` y todos sus volumenes, en este ejemplo unicamente tiene montado `/dokuwiki`:
  ```
  [root@fe02v-oper scripts]# containerBck.sh -n dokuwiki_pro -a
  Container dokuwiki_pro seleccionado...

  Creando imagen del estado actual del container:
  sha256:98b0c2965656976e3ee3cebe30b3cbca92c9df67158a8dedfc979175b23f8f29

  Guardando imagen como .tar.gz
  Realizando backup de todos los volumenes montados: /dokuwiki
  tar: Eliminando la `/' inicial de los nombres
  Se ha creado el dokuwikiVol-dokuwiki_pro_20180621_050001.tar.gz en /backups
  ```
