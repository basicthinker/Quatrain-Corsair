set terminal postscript eps enhanced font 24
set size 1,1
set output "eva-corsair.eps"
set style fill pattern 2 border -1
set style data histograms
set style histogram cluster gap 1
set ylabel 'AAT (ms)'
set yrange [100:5000]
set ytics ("100" 100, "200" 200, "" 300, "400" 400, "" 500, "600" 600, "" 700, "800" 800, "" 900, "1000" 1000, "2000" 2000, "3000" 3000, "4000" 4000)
set logscale y
set border 3
set xtics nomirror
set ytics nomirror
set key below box
plot 'corsair.log' using 2:xtic(1) axes x1y1 title "Normal std", \
    '' using 3:xtic(1) axes x1y1 title "Normal mr", \
    '' using 4:xtic(1) axes x1y1 title "Failure std" lt 1, \
    '' using 5:xtic(1) axes x1y1 title "Failure mr" lt 1
