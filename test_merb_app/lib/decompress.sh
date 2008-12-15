#!/bin/bash

# decompress - will decompress a file, regardless of compression type.
# from: http://snippets.dzone.com/posts/show/5785

Z="compress -d"
gz="gunzip"
bz="bunzip2"
zip="unzip -qo"
rar="unrar x -id -y"
tar="tar xf"
#7z="p7zip -d"

if [ $# -eq 0 ]; then
  echo "Usage: decompress file or files to decompress">&2
  exit 1
fi

for name
do
if [ ! -f "$name" ] ; then
  echo "$0: file $name not found. Skipped." >&2
  continue
fi

if [ "$(echo $name | egrep '(\.Z$|\.gz$|\.bz2$|\.zip$|\.rar$|\.tar$|\.tgz$|\.7z$)')" = "" ] ; then
  echo "Skipped file ${name}: it's already decompressed." 
  continue
fi

extension=${name##*.}

case "$extension" in
  Z ) echo "Filetype is Z. Decompressing..."
    $Z "$name"
    ;;
  gz ) echo "Filetype is gz. Decompressing..."
    $gz "$name"
    ;;
  bz2 ) echo "Filetype is bz2. Decompressing..."
    $bz "$name"
    ;;
  zip ) echo "Filetype is zip. Decompressing..."
    $zip "$name"
    ;;
  rar ) echo "Filetype is rar. Decompressing..."
    $rar "$name"
    ;;
  tar ) echo "Filetype is tar. Decompressing..."
    $tar "$name"
    ;;
  tgz ) echo "Filetype is tgz. Decompressing..."
    $tar "$name"
    ;;
#  7z ) echo "Filetype is 7z. Decompressing..."
#    $7z "$name"
esac
done
exit 0
