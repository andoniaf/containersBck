#! /bin/bash

# Script para backup de contenedores Docker

bckDir="/backups"
# Ver 'man date' para consultar el formato de los modificadores de fecha
bckRetention="10 days ago"

timestamp=$(date +%Y%m%d_%H%M%S)

usage() {
  echo "
    Usage: $0 -n nombreContainer [-o|-a|-v \"vol1 vol2\"]

      -o   Solo backup de los volumenes
      -a   Backup de todos los volumnes del contenedor
      -v   Backup de los volumenes indicados (entrecomillados.
  "
}

targzDir() {
  numVol=0
  for vol in $vols;do
    if [ "$(basename $vol)" == "_data" ];then
      volName=${vol}_$numVol
      numVol=$(($numVol+1))
    else
      volName=${vol}
    fi
    tarName="$(basename $volName)Vol-${conName}_${timestamp}.tar.gz"
    tar -zcf $bckDir/$tarName $vol
    echo "Se ha creado el $tarName en $bckDir"
  done
}


while getopts ":n:oav:" opt; do
  case $opt in
    n)
      conName=$OPTARG
      ;;
    o)
      onlyVol=True
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
else
  usage
  exit 1
fi

if [ ! $onlyVol ];then
  echo "Creando imagen del estado actual del container:"
  docker commit $conName ${conName}:$timestamp
  echo

  echo "Guardando imagen como .tar.gz"
  docker save --output=$bckDir/${conName}_${timestamp}.tar ${conName}:$timestamp
  gzip -9 $bckDir/${conName}_${timestamp}.tar
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
