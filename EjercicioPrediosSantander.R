library(rgdal)    # Importación de Datos (puntos, líneas, polígonos)
library(maptools) # Herramientas de Visualización
library(gstat)    # Geoestadística
library(spatstat) # Geoestadística
library(plotly)   # Proyecciones

mapa1 <- readOGR(dsn = '68_R_TERRENO', layer = 'R_TERRENO')

summary(mapa1)
plot(mapa1, border = 'grey')

municipios <- readOGR(dsn = 'Mapas', layer = 'MunicipiosVeredas')
plot(municipios, border = 'red', add = T)

departamentos <- readOGR(dsn = 'Mapas', layer = 'DepartamentosVeredas')
plot(departamentos, border = 'black', add = T)

coord<-coordinates(mapa1)     # Extraemos las coordenadas
coord<-as.data.frame(coord) # Las convertimos en un data.frame ordenado
coord$LON<-coord$V1         # Creamos el vector de Longitud
coord$LAT<-coord$V2         # Creamos el vector de Latitud
# Quitamos lo que no requerimos
coord$V1<-NULL
coord$V2<-NULL
head(coord)


puntos<-data.frame(area=mapa1@data$SHAPE_Area, coord)
head(puntos)

library('ggplot2')

summary(puntos$area)
summary(puntos$area*1e6)
puntos$area<-puntos$area*1e6
puntos$Int<-cut(puntos$area, breaks = c(0,0.5,2,10,6.5,22000))
summary(puntos$Int)
head(mapa1@data)

ggplot(data = na.omit(puntos), aes(LON, LAT)) +
geom_point(pch=3, col="black", size = 0.5) + theme_bw()

airPal <- colorRampPalette(c("springgreen1", "sienna3", "gray5"))(6)
ggplot(data = na.omit(puntos), aes(LON, LAT, size = Int, fill = Int)) + 
  geom_point(pch=21, col="black") + theme_bw() +
  scale_fill_manual(values=airPal)

library(classInt)
nClasses <- 5
intervals <- classIntervals(puntos$area, n=nClasses, style="fisher")
nClasses <- length(intervals$brks) - 1
op <- options(digits=4)
tab <- print(intervals)
options(op)

dent <- c(1,2,3,4,5,6)
dentAQ <- dent[seq_len(nClasses)]
idx <- findCols(intervals)
cexAcui <- dentAQ[idx]

puntos$classarea <- factor(names(tab)[idx])

puntosBox <- bbox(mapa1)
puntosBox
puntosBox<-puntosBox + matrix(data = c(-0.1,-0.1,0.1,0.1), nrow = 2, ncol = 2)

library(ggmap)
puntosGG <- get_map(c(puntosBox), maptype="satellite", source="google")

mapasder<-ggmap(puntosGG) +
  geom_point(data=na.omit(puntos),
             aes(LON, LAT, size=classarea, fill=classarea),
             pch=21, col="black") +
  scale_fill_manual(values=airPal) +
  scale_size_manual(values=dentAQ) +
geom_polygon(data = fortify(departamentos[departamentos@data$DPTO_CCDGO=='68',]),
                  aes(long, lat, group = group),
                  fill = "orange", colour = "red", alpha = 0.2) +
geom_polygon(data = fortify(municipios[municipios@data$DPTO_CCDGO=='68',]),
                  aes(long, lat, group = group),
                  fill = "grey", colour = "black", alpha = 0.2)

print(mapasder)

plot(departamentos[departamentos@data$DPTO_CCDGO=='15',]















