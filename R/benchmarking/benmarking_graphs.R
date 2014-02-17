setwd("C:\\Users\\xzizal\\Desktop\\GitHub\\geocoder\\R\\benchmarking\\")

datR <-read.table("result_Summary.txt", header = T)
datR_graph <- subset(datR,datR$graphs == "yes")
datR_simp <- subset(datR,datR$graphs == "no")

#plot without graphs
#polygons
postscript(file = "bm_no_graph.eps", paper = "special", width = 7.5, height = 5.5)
par(mar = c(4,4,4,4))
plot(log10(datR_simp$datapoints), log10(datR_simp$seconds), type = "n", 
     xlab = "Number of datapoints (log10)", ylab = "Time [sec]", axes = F, xlim = c(0,8))

title("Computing time depending on dataset size (no graphics)")
axis(1, at = c(0, 1, 2, 3, 4, 5, 6, 7, 8), labels = c("1", expression(paste("10"^"1")), expression(paste("10"^"2")),
                                                expression(paste("10"^"3")), expression(paste("10"^"4")),
                                                expression(paste("10"^"5")), expression(paste("10"^"6")),
                                                expression(paste("10"^"7")), expression(paste("10"^"8"))))
axis(2, las = 2, at = c(-1, 0, 1, 2, 3, 4, 5),
     labels = c(0, 1, expression(paste("10"^"1")),
                expression(paste("10"^"2")), expression(paste("10"^"3")),
                expression(paste("10"^"4")), expression(paste("10"^"5"))))

axis(4, at = c(0,log10(c(6, 60, 600,1800,3600,36000))), labels = c(0, 0.1,1,10,30,60,600), las = 2)
mtext(side = 4, "Time [min]", line = 2.5)

points(log10(subset(datR_simp,datR_simp$polygons == 10)$datapoints),
       log10(subset(datR_simp,datR_simp$polygons == 10)$seconds), type = "b", lty = 2, pch = 2)

points(log10(subset(datR_simp,datR_simp$polygons == 100)$datapoints),
       log10(subset(datR_simp,datR_simp$polygons == 100)$seconds), type = "b", lty = 3, pch = 3)

points(log10(subset(datR_simp,datR_simp$polygons == 1000)$datapoints),
       log10(subset(datR_simp,datR_simp$polygons == 1000)$seconds), type = "b", lty = 4, pch = 4)

points(log10(subset(datR_simp,datR_simp$polygons == 10000)$datapoints),
       log10(subset(datR_simp,datR_simp$polygons == 10000)$seconds), type = "b", lty = 5, pch = 5)
legend("bottomright",legend = c(10,100,1000,10000), 
       pch = c(2,3,4,5), lty="99", title = "No of polygons")
box("plot")
dev.off()

#with graphics
postscript(file = "bm_graphics.eps", paper = "special", width = 7.5, height = 5.5)
par(mar = c(4,4,4,4))
plot(log10(datR_graph$datapoints), log10(datR_graph$seconds), type = "n", 
     xlab = "Number of datapoints (log10)", ylab = "Time [sec]", axes = F, xlim = c(0,8))

title("Computing time depending on dataset size (with graphics)")
axis(1, at = c(0, 1, 2, 3, 4, 5, 6, 7, 8), labels = c("1", expression(paste("10"^"1")), expression(paste("10"^"2")),
                                                      expression(paste("10"^"3")), expression(paste("10"^"4")),
                                                      expression(paste("10"^"5")), expression(paste("10"^"6")),
                                                      expression(paste("10"^"7")), expression(paste("10"^"8"))))
axis(2, las = 2, at = c(-1, 0, 1, 2, 3, 4, 5),
     labels = c(0, 1, expression(paste("10"^"1")),
                expression(paste("10"^"2")), expression(paste("10"^"3")),
                expression(paste("10"^"4")), expression(paste("10"^"5"))))

axis(4, at = c(0,log10(c(6, 60, 600,1800,3600,36000))), labels = c(0, 0.1,1,10,30,60,600), las = 2)
mtext(side = 4, "Time [min]", line = 2.5)

points(log10(subset(datR_graph,datR_graph$polygons == 10)$datapoints),
       log10(subset(datR_graph,datR_graph$polygons == 10)$seconds), type = "b", lty = 2, pch = 2)

points(log10(subset(datR_graph,datR_graph$polygons == 100)$datapoints),
       log10(subset(datR_graph,datR_graph$polygons == 100)$seconds), type = "b", lty = 3, pch = 3)

points(log10(subset(datR_graph,datR_graph$polygons == 1000)$datapoints),
       log10(subset(datR_graph,datR_graph$polygons == 1000)$seconds), type = "b", lty = 4, pch = 4)

points(log10(subset(datR_graph,datR_graph$polygons == 10000)$datapoints),
       log10(subset(datR_graph,datR_graph$polygons == 10000)$seconds), type = "b", lty = 5, pch = 5)
legend("bottomright",legend = c(10,100,1000,10000), 
       pch = c(2,3,4,5), lty="99", title = "No of polygons")
box("plot")
dev.off()


