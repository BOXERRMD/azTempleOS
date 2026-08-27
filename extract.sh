#! /bin/sh

find ./TempleOS_source_code/ -type f -name "*.Z" | while IFS= read -r ligne
do
	./TOSZ/tosz -ascii "$ligne"
done
