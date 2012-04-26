set boxwidth 1 relative
set style data histogram
set title "WCET Benchmarks Instruction Throughput (higher is better)"
set ylabel "instruction throughput (instructions/cycle)"
set xtics nomirror rotate by -45
set yrange [0:1.3]
set grid
set lmargin 4
set tmargin 0
set rmargin 0
set bmargin 1
set term postscript enhanced "Helvetica" 20
set output "wcet_throughput.ps"


plot 'ptarm_sim.dat' using 2: xtic(1) title 'PTARM' fs solid 1.00 lt -1,\
     'SA1100_cold.dat' using 2: xtic(1) title 'SA1100 cold' fs solid 0.33 lt -1,\
     'SA1100_warm.dat' using 2: xtic(1) title 'SA1100 warm' fs solid 0.66 lt -1,\
     'SA1100_nomem.dat' using 2: xtic(1) title 'SA1100 allcache' fs solid 0.00 lt -1
