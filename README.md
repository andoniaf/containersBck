# containersBck

- Script para respaldo de contenedores Docker (y sus volúmenes).

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
  - `-o`: Solo backup de los volúmenes.
  - `-a`: Backup de todos los volúmenes del contenedor.
  - `-v`: Backup de los volúmenes indicados entre las comillas.



### Ejemplo de uso:

 - Backup del contenedor `dokuwiki_pro` y todos sus volúmenes, en este ejemplo unicamente tiene montado `/dokuwiki`:
  ```
  [root@venom scripts]# containerBck.sh -n dokuwiki_pro -a
  Container dokuwiki_pro seleccionado...

  Creando imagen del estado actual del container:
  sha256:98b0c2965656976e3ee3cebe30b3cbca92c9df67158a8dedfc979175b23f8f29

  Guardando imagen como .tar.gz
  Backup de todos los volumenes montados: /dokuwiki
  tar: Eliminando la `/' inicial de los nombres

  Se ha creado el dokuwikiVol-dokuwiki_pro_20180621_050001.tar.gz en /backups
  ```

- Backup únicamente de los volúmenes del contenedor:
  ```
  aalonsof@wasp scripts]# ./containerBck.sh -n competent_hodgkin -oa                   
  Container competent_hodgkin seleccionado...

  Realizando backup únicamente de los volumenes...

  Backup de todos los volumenes montados: /home/aalonsof/git/andoniaf.github.io
  tar: Eliminando la `/' inicial de los nombres

  Se ha creado el andoniaf.github.ioVol-competent_hodgkin_20180623_101032.tar.gz en /backups
  ```
