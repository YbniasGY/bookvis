(TeX-add-style-hook "rasterST"
 (lambda ()
    (LaTeX-add-index-entries
     "Packages!raster@\\texttt{raster}"
     "Packages!zoo@\\texttt{zoo}"
     "Packages!rasterVis@\\texttt{rasterVis}"
     "setZ@\\texttt{setZ}"
     "levelplot@\\texttt{levelplot}"
     "zApply@\\texttt{zApply}"
     "histogram@\\texttt{histogram}"
     "bwplot@\\texttt{bwplot}"
     "splom@\\texttt{splom}"
     "hovmoller@\\texttt{hovmoller}"
     "xyplot@\\texttt{xyplot}"
     "horizonplot@\\texttt{horizonplot}"
     "Packages!maptools@\\texttt{maptools}"
     "Packages!mapdata@\\texttt{mapdata}"
     "Packages!maps@\\texttt{maps}"
     "Packages!rgdal@\\texttt{rgdal}"
     "map2SpatialLines@\\texttt{map2SpatialLines}"
     "spTransform@\\texttt{spTransform}"
     "brewer.pal@\\texttt{brewer.pal}"
     "ffmpeg@\\texttt{ffmpeg}")
    (LaTeX-add-labels
     "sec-1"
     "sec-2"
     "fig:SISdm"
     "fig:SISmm"
     "sec-3"
     "fig:SISdm_hist"
     "fig:SISdm_boxplot"
     "fig:SISmm_splom"
     "sec-4"
     "fig:SISdm_hovmoller_lat"
     "fig:SISmm_xyplot"
     "fig:SISdm_horizonplot"
     "sec-5"
     "sec:animationST"
     "fig:cft")))
