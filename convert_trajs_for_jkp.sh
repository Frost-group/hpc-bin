

echo trjconv -b 1000 -pbc whole -f traj.trr -o ${1%.*}_traj_nojump_dt10ps.xtc -s $1 -dt 10
