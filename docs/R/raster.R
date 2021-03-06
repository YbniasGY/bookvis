##################################################################
## Initial configuration
##################################################################
## Clone or download the repository and set the working directory
## with setwd to the folder where the repository is located.

##################################################################
## Quantitative data
##################################################################

library(raster)
library(rasterVis)

SISav <- raster('data/SISav')

levelplot(SISav)

library(maps)
library(mapdata)
library(maptools)
## Extent of the Raster object
ext <- as.vector(extent(SISav))
## Retrieve the boundaries restricted to this extent
boundaries <- map('worldHires',
                  xlim = ext[1:2], ylim = ext[3:4],
                  plot = FALSE)
## Convert the result to a SpatialLines object with the projection of
## the Raster object
boundaries <- map2SpatialLines(boundaries,
                               proj4string = CRS(projection(SISav)))

## Display the Raster object ...
levelplot(SISav) +
    ## ... and overlay the SpatialLines object
    layer(sp.lines(boundaries,
                   lwd = 0.5))

##################################################################
## Hill shading
##################################################################

old <- setwd(tempdir())
download.file('http://biogeo.ucdavis.edu/data/diva/msk_alt/ESP_msk_alt.zip', 'ESP_msk_alt.zip')
unzip('ESP_msk_alt.zip', exdir = '.')

DEM <- raster('ESP_msk_alt')

slope <- terrain(DEM, 'slope')
aspect <- terrain(DEM, 'aspect')
hs <- hillShade(slope = slope, aspect = aspect,
                angle = 60, direction = 45)

setwd(old)

## hillShade theme: gray colors and semitransparency
hsTheme <- GrTheme(regions = list(alpha = 0.5))

levelplot(SISav,
          par.settings = YlOrRdTheme,
          margin = FALSE, colorkey = FALSE) +
    ## Overlay the hill shade raster
    levelplot(hs, par.settings = hsTheme, maxpixels = 1e6) +
    ## and the countries boundaries
    layer(sp.lines(boundaries, lwd = 0.5))

##################################################################
## Diverging palettes
##################################################################

meanRad <- cellStats(SISav, 'mean')
SISav <- SISav - meanRad

xyplot(layer ~ y, data = SISav,
       groups = cut(x, 5),
       par.settings = rasterTheme(symbol = plinrain(n = 5,
                                                    end = 200)),
       xlab = 'Latitude', ylab = 'Solar radiation (scaled)',  
       auto.key = list(space = 'right',
                       title = 'Longitude',
                       cex.title = 1.3))

divPal <- brewer.pal(n = 9, 'PuOr')
divPal[5] <- "#FFFFFF"

showPal <- function(pal)
{
    N <- length(pal)
    image(1:N, 1, as.matrix(1:N), col = pal,
          xlab = '', ylab = '',
          xaxt = "n", yaxt = "n",
          bty = "n")
}

showPal(divPal)

divTheme <- rasterTheme(region = divPal)

levelplot(SISav, contour = TRUE, par.settings = divTheme)

rng <- range(SISav[])
## Number of desired intervals
nInt <- 15
## Increment corresponding to the range and nInt
inc0 <- diff(rng)/nInt
## Number of intervals from the negative extreme to zero
n0 <- floor(abs(rng[1])/inc0)
## Update the increment adding 1/2 to position zero in the center of an interval
inc <- abs(rng[1])/(n0 + 1/2)
## Number of intervals from zero to the positive extreme
n1 <- ceiling((rng[2]/inc - 1/2) + 1)
## Collection of breaks
breaks <- seq(rng[1], by = inc, length= n0 + 1 + n1)

## Midpoints computed with the median of each interval
idx <- findInterval(SISav[], breaks, rightmost.closed = TRUE)
mids <- tapply(SISav[], idx, median)
## Maximum of the absolute value both limits
mx <- max(abs(breaks))

break2pal <- function(x, mx, pal){
    ## x = mx gives y = 1
    ## x = 0 gives y = 0.5
    y <- 1/2*(x/mx + 1)
    rgb(pal(y), maxColorValue = 255)
}

## Interpolating function that maps colors with [0, 1]
## rgb(divRamp(0.5), maxColorValue=255) gives "#FFFFFF" (white)
divRamp <- colorRamp(divPal)
## Diverging palette where white is associated with the interval
## containing the zero
pal <- break2pal(mids, mx, divRamp)
showPal(pal)

levelplot(SISav,
          par.settings = rasterTheme(region = pal),
          at = breaks, contour = TRUE)

divTheme <- rasterTheme(regions = list(col = pal))

levelplot(SISav,
          par.settings = divTheme,
          at = breaks,
          contour = TRUE)

library(classInt)

cl <- classIntervals(SISav[], style = 'kmeans')
breaks <- cl$brks

## Repeat the procedure previously exposed, using the 'breaks' vector
## computed with classIntervals
idx <- findInterval(SISav[], breaks, rightmost.closed = TRUE)
mids <- tapply(SISav[], idx, median)

mx <- max(abs(breaks))
pal <- break2pal(mids, mx, divRamp)

## Modify the vector of colors in the 'divTheme' object
divTheme$regions$col <- pal

levelplot(SISav,
          par.settings = divTheme,
          at = breaks,
          contour = TRUE)

##################################################################
## Categorical data
##################################################################

## China and India  
ext <- extent(65, 135, 5, 55)

pop <- raster('data/875430rgb-167772161.0.FLOAT.TIFF')
pop <- crop(pop, ext)
pop[pop==99999] <- NA

landClass <- raster('data/241243rgb-167772161.0.TIFF')
landClass <- crop(landClass, ext)

landClass[landClass %in% c(0, 254)] <- NA
## Only four groups are needed:
## Forests: 1:5
## Shrublands, etc: 6:11
## Agricultural/Urban: 12:14
## Snow: 15:16
landClass <- cut(landClass, c(0, 5, 11, 14, 16))
## Add a Raster Attribute Table and define the raster as categorical data
landClass <- ratify(landClass)
## Configure the RAT: first create a RAT data.frame using the
## levels method; second, set the values for each class (to be
## used by levelplot); third, assign this RAT to the raster
## using again levels
rat <- levels(landClass)[[1]]
rat$classes <- c('Forest', 'Land', 'Urban', 'Snow')
levels(landClass) <- rat

qualPal <- c('palegreen4', # Forest
         'lightgoldenrod', # Land
         'indianred4', # Urban
         'snow3')      # Snow

qualTheme <- rasterTheme(region = qualPal,
                        panel.background = list(col = 'lightskyblue1')
                        )

levelplot(landClass, maxpixels = 3.5e5,
          par.settings = qualTheme)

pPop <- levelplot(pop, zscaleLog = 10,
                  par.settings = BTCTheme,
                  maxpixels = 3.5e5)
pPop

## Join the RasterLayer objects to create a RasterStack object.
s <- stack(pop, landClass)
names(s) <- c('pop', 'landClass')

densityplot(~log10(pop), ## Represent the population
            groups = landClass, ## grouping by land classes
            data = s,
            ## Do not plot points below the curves
            plot.points = FALSE)

##################################################################
## Bivariate legend
##################################################################

classes <- rat$classes
nClasses <- length(classes)

logPopAt <- c(0, 0.5, 1.85, 4)

nIntervals <- length(logPopAt) - 1

multiPal <- sapply(1:nClasses, function(i)
{
    colorAlpha <- adjustcolor(qualPal[i], alpha = 0.4)
    colorRampPalette(c(qualPal[i],
                       colorAlpha),
                     alpha = TRUE)(nIntervals)
})

pList <- lapply(1:nClasses, function(i){
    landSub <- landClass
    ## Those cells from a different land class are set to NA...
    landSub[!(landClass==i)] <- NA
    ## ... and the resulting raster masks the population raster
    popSub <- mask(pop, landSub)
    ## Palette
    pal <- multiPal[, i]

    pClass <- levelplot(log10(popSub),
                        at = logPopAt,
                        maxpixels = 3.5e5,
                        col.regions = pal,
                        colorkey = FALSE,
                        margin = FALSE)
})

p <- Reduce('+', pList)

library(grid)

legend <- layer(
{
    ## Center of the legend (rectangle)
    x0 <- 125
    y0 <- 22
    ## Width and height of the legend
    w <- 10
    h <- w / nClasses * nIntervals
    ## Legend
    grid.raster(multiPal, interpolate = FALSE,
                      x = unit(x0, "native"),
                      y = unit(y0, "native"),
                width = unit(w, "native"))
    ## Axes of the legend
    ## x-axis (qualitative variable)
    grid.text(classes,
              x = unit(seq(x0 - w * (nClasses -1)/(2*nClasses),
                           x0 + w * (nClasses -1)/(2*nClasses),
                           length = nClasses),
                       "native"),
              y = unit(y0 + h/2, "native"),
              just = "bottom",
              rot = 10,
              gp = gpar(fontsize = 6))
    ## y-axis (quantitative variable)
    yLabs <- paste0("[",
                    paste(logPopAt[-nIntervals],
                          logPopAt[-1], sep = ","),
                    "]")
    grid.text(yLabs,
              x = unit(x0 + w/2, "native"),
              y = unit(seq(y0 - h * (nIntervals -1)/(2*nIntervals),
                           y0 + h * (nIntervals -1)/(2*nIntervals),
                           length = nIntervals),
                       "native"),
              just = "left",
              gp = gpar(fontsize = 6))

})

p + legend

##################################################################
## 3D visualization
##################################################################

plot3D(DEM, maxpixels = 5e4)

## Dimensions of the window in pixels
par3d(viewport = c(0, 30, ## Coordinates of the lower left corner
                   250, 250)) ## Width and height

writeWebGL(filename = 'docs/images/rgl/DEM.html',
           width = 800)

##################################################################
## mapview
##################################################################

library(mapview)

mvSIS <- mapview(SISav, legend = TRUE)

SIAR <- read.csv("data/SIAR.csv")

spSIAR <- SpatialPointsDataFrame(coords = SIAR[, c("lon", "lat")], 
                                 data = SIAR,
                                 proj4str = CRS(projection(SISav)))

mvSIAR <- mapview(spSIAR,
                  label = spSIAR$Estacion)

mvSIS + mvSIAR
