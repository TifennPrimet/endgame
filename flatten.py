import cv2 as cv2
from read_calib_matrix import *
from undistord_img import * 
def flatten(fImName, XMLName) :

    img = cv.imread(fImName, cv.IMREAD_UNCHANGED)

    camMtx, distV = read_calib_matrix(XMLName)

    imgUndistord = undistord_img(img, camMtx, distV)
  
    return imgUndistord

#flatten("C:/Users/tprimet/Documents/REPRISE/MS/MS1_unziped/20220519_134340/imgChannel_0.tiff","C:/Users/tprimet/Documents/REPRISE/XML/MatriceMS1.xml")