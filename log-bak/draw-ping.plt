set terminal postscript eps color enhanced font 20
set output "eva-corsair-ping.eps"
set size 1, 0.7

set style fill solid 1 border -1
set style data histograms
set style histogram cluster
set xlabel 'Instance sending ECHO\_REQUEST'
set ylabel 'Round trip time (ms)'
set yrange [0:300]
set border 3
set xtics nomirror
set ytics nomirror
set xrange [-0.5:10]
set key horizontal
plot 'ping-node.log' using 2:xtic(1) title "Average", \
    'ping-node.log' using 3:xtic(1) title "Difference"
