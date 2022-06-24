from dataclasses import replace
from importlib.resources import path
import numpy as np
#☺import matplotlib.pyplot as plt
from skimage import data
from skimage.registration import phase_cross_correlation
from skimage.registration._phase_cross_correlation import _upsampled_dft
from scipy.ndimage import fourier_shift
from skimage.transform import warp
import glob
import cv2 as cv
def cross_correlation_shift(Path, Path_folder):
    """" Function that calculate the shift between two cameras according to the 8th channel
    Parameters :
    ----------
    Path : string
        name of the path to the file of reference 
    Path_folder : string
        path to the folder of images to shift
    Returns :
    ---------
    res : list 
        list of all the matrix (images) shifted
    """
    # --- Load the sequence
    image = cv.imread(Path, cv.IMREAD_UNCHANGED)
    folderToTransforme = glob.glob(Path_folder + '/*' + 'tiff', recursive= True)
    # load the 8th channel (correpond to the B&W channel)
    # for foldername in folderToTransforme : 
    #   if 'imgChannel_8' in foldername : 
    PathBis = Path_folder+'/imgChannel_8.tiff'
      
    print("image a décaler  =",PathBis,"\n image de depart", Path )
    print("image", image)
    offset_image = cv.imread(PathBis , cv.IMREAD_UNCHANGED)

    # we first compute a raw shift between the 2 cameras
    shift, error, diffphase = phase_cross_correlation(image, offset_image) #, space ="real")
    print(f'Detected pixel offset (y, x): {shift}')
    shiftx = shift[0]
    shifty = shift[1]
    
    # then we refine the shift (but it's possible to just shift the image with the raw shift)
    dt = 0.01
    dx = np.arange(shift[0]-1 , shift[0]+1+dt , dt)
    dy = np.arange(shift[1]-1 , shift[1]+1+dt , dt)
    resX = np.zeros(dx.shape)
    resY = np.zeros(dy.shape)
    for i in range (dx.shape[0] ):
      if dx[i]!=0 :
            offset_image_copy = fourier_shift(np.fft.fftn(offset_image),( dx[i] , 1))
            offset_image_copy = np.fft.ifftn(offset_image_copy)
            shift, error, diffphase = phase_cross_correlation(image, offset_image_copy , upsample_factor=20)
            resX[i] = shift[0]
    for j in range(dy.shape[0]) :
      if dy[j]!=0 :
          offset_image_copy = fourier_shift(np.fft.fftn(offset_image), (1 , dy[j]))
          offset_image_copy = np.fft.ifftn(offset_image_copy)
          shift, error, diffphase = phase_cross_correlation(image, offset_image_copy,upsample_factor=20)
          resY[j] = shift[1]
            

    shiftx = dx[np.where(resX == np.min(np.abs(resX)))[0][0]]
    shifty = dy[np.where(resY == np.min(np.abs(resY)))[0][0]]
    res =[]
    for foldername in folderToTransforme :
      offset_image = cv.imread(foldername , cv.IMREAD_UNCHANGED)
      nr, nc = offset_image.shape
      row_coords, col_coords = np.meshgrid(np.arange(nr), np.arange(nc), indexing='ij')
      warped_image = warp(offset_image, np.array([row_coords - shiftx, col_coords - shifty]), mode='edge')
      res.append(warped_image)
    return  res

Path = "C:/Users/tprimet/Documents/REPRISE/MS/MS2_flat/20220519_134340/imgChannel_8.tiff"
pathBis = "C:/Users/tprimet/Documents/REPRISE/MS/MS1_flat/20220519_134340"
cross_correlation_shift(Path, pathBis)