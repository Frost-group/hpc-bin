for file
do
for i in 15 16 17 18 19 20 21 22 23 25 30
do
 cat "${file}" | sed s/CAM/0.${i}/ > "${file%.*}_CAMp${i}.nw"
done
done
