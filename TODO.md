# TODO

* [ ] Revisar la parte del `basename $vol`, ya que si el contenedor este creado como:
```
  docker run --rm  -it -v testVol1 -v testVol2 ubuntu /bin/bash
```
Los volumenes se crean automaticamente sobre `/var/lib/docker/volumes` y ambos se llamarían `_data`:

```
[root@fe02v-oper scripts]# docker inspect -f '{{ range .Mounts }}{{ .Source }} {{ end }}' 0dec7e6ba4c4
/var/lib/docker/volumes/9876f78c2803e180a52ca2c0533611b15ab8b003b672bfd583df60ef8960209e/_data /var/lib/docker/volumes/4cc0271d3c47613f77547faab4a57b2f92e8905a89b5fa3e1eb4f029dbaa7671/_data
```
  - Comprobar si se llaman '_data' y añadir un '01', '02', etc (?)
