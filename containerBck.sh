#! /bin/bash

# Script para backup de contenedores Docker

bckDir="/backups"
timestamp=$(date +%Y%m%d_%H%M%S)
# Ver 'man date' para consultar el formato de los modificadores de fecha
bckRetention="10 days ago"

usage() {
  echo "
    Usage: $0 -n nombreContainer [-a|-v \"vol1 vol2\"]

      -a   Backup de todos los volumnes del contenedor
      -v   Backup de los volumenes indicados (entrecomillados.
  "
}

targzDir() {
  numVol=0
  for vol in $vols;do
    if [ $(basename $vol) == "_data" ];then
      vol=${vol}_$numVol
      numVol=$(($numVol+1))
    fi
    tarName="$(basename $vol)Vol-${conName}_${timestamp}.tar.gz"
    echo "tar -zcf $bckDir/$tarName $vol"
    echo "Se ha creado el $tarName en $bckDir"
  done
}


while getopts ":n:av:" opt; do
  case $opt in
    n)
      conName=$OPTARG
      ;;
    a)
      bckVolumes() {
        vols=$(docker inspect -f '{{ range .Mounts }}{{ .Source }} {{ end }}' $conName)
        echo "Realizando backup de todos los volumenes montados: $vols"
        targzDir
      }
      bckVol=True
      ;;
    v)
      vols=$OPTARG
      bckVolumes() {
        echo "Realizando backup de los siguientes volumenes: $vols"
        targzDir
      }
      bckVol=True
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo
      usage
      exit 2
      ;;
  esac
done

if [ $conName ];then
  echo "Container $conName seleccionado..."
  echo
  echo "Creando imagen del estado actual del container:"
  docker commit $conName ${conName}:$timestamp
  echo

  echo "Guardando imagen como .tar.gz"
  docker save --output=$bckDir/${conName}_${timestamp}.tar.gz ${conName}:$timestamp
else
  usage
  exit 1
fi

if [ $bckVol ];then bckVolumes;fi

# Borrado de imagenes antiguas
for tag in $(docker images --filter=reference="$conName:*" --format 'table {{.Tag}}' | tail -n +2 | tr -d '_');do
  if [ $(date +%Y%m%d%H%M%S --date="$bckRetention") -ge $tag ];then
    echo "Borrando imagen: $conName:$tag"
    docker rmi $conName:$tag
  fi
done

# Borrado volumenes e imagenes exportadas (tar.gz) antiguas
find $bckDir -name "*$conName*tar.gz" ! -newermt "$(date "+%Y%m%d %H:%M" --date="$bckRetention" )" -delete
