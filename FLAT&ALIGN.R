#---------------------------------------------------------------------------------ALL IMPORTS----------------------
library(reticulate)
library(tiff)
#library(imager)
library(raster)
# Loading required package: sp
library(stringr)
library(tiff)

#virtualenv_create("r-reticulate")
virtualenv_install("r-reticulate", "opencv-python")
virtualenv_install("r-reticulate", "tifffile")
virtualenv_install("r-reticulate", "scikit-image")
virtualenv_install("r-reticulate", "matplotlib")
#virtualenv_list() 
#py_discover_config()
# reticulate::import_from_path("cv2", path = "C:/Users/tprimet/AppData/Local/r-miniconda/envs/r-reticulate/Lib/site-packages/cv2", delay_load = FALSE)
reticulate::import_from_path("cv2", path = "C:/Users/tprimet/Documents/.virtualenvs/r-reticulate/Lib/site-packages/cv2", delay_load = FALSE)
reticulate::import_from_path("tifffile", path = "C:/Users/tprimet/Documents/.virtualenvs/r-reticulate/Lib/site-packages/tifffile", delay_load = FALSE)
# reticulate::import_from_path("matplotlib" , path = "C:/Users/tprimet/AppData/Local/r-miniconda/envs/r-reticulate/Lib/site-packages/matplotlib",  delay_load = FALSE)
reticulate::import_from_path("skimage" , path = "C:/Users/tprimet/AppData/Local/r-miniconda/envs/r-reticulate/Lib/site-packages/skimage",  delay_load = FALSE)
#use_virtualenv
cv = import("cv2")
tif = import("tifffile")
skimage = import("skimage")
py_install(packages = "matplotlib")
py_install(packages = "scikit-image")
# = import("matplotlib.pyplot")
flat = import("flatten")
shift = import('cross_correlation_shift')

#-------------------------------------------------------------------------------FUNCTIONS NEEDED TO WORK (not mine)
arrange_channels <- function(x) {
  ms1 <- sort(x[grep("MS1_", x)])
  ms2 <- sort(x[grep("MS2_", x)])
  c(ms1, ms2)
}
as_raster <- function(x, xmx = 426, ymx = 339) {
  if(is.matrix(x)) {
    r <- raster::raster(x, xmn=0, xmx=xmx, ymn=0, ymx=ymx)
  } else {
    r <- raster::stack(apply(x, 3, raster::raster, xmn=0, xmx=xmx, ymn=0, ymx=ymx))
  }
  r
}

write_cube <- function(x, file, onefile = TRUE, overwrite = TRUE, ...) {
  if(! class(x) %in% c("RasterLayer", "RasterStack", "RasterBrick")) {
    x <- as_raster(x)
  }
  if (onefile) {
    raster::writeRaster(x, file,
                        datatype = "INT2U", overwrite = overwrite,
                        gdal=c("COMPRESS=NONE", "PROFILE=BASELINE"), ...)
    
  } else {
    for (i in 1:raster::nlayers(x)) {
      filei <- gsub("\\.tif", paste0("_", i-1, ".tif"), file)
      print(filei)
      raster::writeRaster(raster::raster(x, i), filei,
                          datatype = "INT2U", overwrite = overwrite,
                          gdal=c("COMPRESS=NONE", "PROFILE=BASELINE"), ...)
    }
  }
}



#-------------------------------------------------------------------------------The function I created 


flatten_img <- function(base, base_path,xml_PathName){
  all_files <- list.files(base_path, pattern = "img", full.names = TRUE)
  cubestack <- stack((arrange_channels(all_files)))
  plotRGB(cubestack, scale = 255, stretch = "lin")
  flattened1 <- lapply(all_files, function(x) flat$flatten(x, xml_PathName))
  cubestackFlat <- raster::stack(lapply(flattened1, as_raster))
  plotRGB(cubestackFlat, scale = 255, stretch = "lin")
  
  base_path_flat = str_replace(base_path, "unziped", "flat")
  base_flat= str_replace(base, "unziped", "flat")
  if(!file.exists(base_flat)){
    dir.create(base_flat)
  }
  
  if(!file.exists(base_path_flat)){
    dir.create(base_path_flat)
  }
  
  base_path_flat = str_replace(all_files[1], "unziped", "flat")
  base_path_flat = str_replace(base_path_flat, "_0", "")
  write_cube(cubestackFlat, base_path_flat , onefile= FALSE)   # here the problem
  cubestackFlat
}


#----------------------flattening the MS1 folder n*20220519_134340
base_path = "C:/Users/tprimet/Documents/REPRISE/MS/MS1_unziped/20220519_134340"
base = "C:/Users/tprimet/Documents/REPRISE/MS/MS1_unziped"
xml_PathName = "C:/Users/tprimet/Documents/REPRISE/XML/MatriceMS1.xml"
CubeStackFlatMS1 = flatten_img(base, base_path, xml_PathName)
#MS2)
raster::plotRGB(CubeStackFlatMS1, scale = 255, stretch = "lin")

#----------------------flattening the MS2 folder n*20220519_134340
base_pathMS2 = "C:/Users/tprimet/Documents/REPRISE/MS/MS2_unziped/20220519_134340"
baseMS2 = "C:/Users/tprimet/Documents/REPRISE/MS/MS2_unziped"
#all_files2 <- list.files(base_path, pattern = "img", full.names = TRUE)
# xml_PathName = "C:/Users/tprimet/Documents/REPRISE/XML/MatriceMS1.xml"
CubeStackFlatMS2 = flatten_img(baseMS2, base_pathMS2, xml_PathName)
raster::plotRGB(CubeStackFlatMS2, scale = 255, stretch = "lin")
#---------------------Shift the files according to the 8th band

pathMS2 = "C:/Users/tprimet/Documents/REPRISE/MS/MS2_flat/20220519_134340"
base_pathMS1 = "C:/Users/tprimet/Documents/REPRISE/MS/MS1_flat/20220519_134340"
all_files2 <- list.files(base_pathMS1, pattern = "img", full.names = TRUE)
shiffted = shift$cross_correlation_shift(all_files2[9], pathMS2)
cubestackshiftMS2 <- raster::stack(lapply(shiffted, as_raster))
vis_nir <- raster::stack(CubeStackFlatMS2, cubestackshiftMS2)
raster::plotRGB(vis_nir, scale = 255, stretch = "lin")


# display the image red is changing all the time 
for(i in 1 : 18){
raster::plotRGB(vis_nir, r= i, g = 18, b= 9, scale = 4095, stretch= "lin")
}


path_cube = str_replace("C:/Users/tprimet/Documents/REPRISE/MS/MS2_flat", "MS2_flat", "CUBE")
base_path_cube = paste0(str_replace(base_path, "MS1_flat", "CUBE"), ".tiff")

if(!file.exists(path_cube)){
  dir.create(path_cube)
}
write_cube(vis_nir, base_path_cube)

dim(vis_nir)

nishift = raster::stack(CubeStackFlatMS1, CubeStackFlatMS2)
raster::plotRGB(nishift, r= 1, g = 18, b= 9, scale = 4095, stretch= "lin")