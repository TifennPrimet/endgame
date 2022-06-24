import xml.etree.ElementTree as ET
import cv2 as cv

def read_calib_matrix(fname): 
    """"
    Function that read the XML file made with Metashape and gives the camera matrix and distortion coefficients
    Parameters
    ----------
    fname : string
        name of the XML file

    Returns
    -------
    mtx : <class 'list'>
        camera matrix
    dist : <class 'numpy.ndarray'>
        distortion coefficients
    """
    fs = cv.FileStorage(fname, cv.FILE_STORAGE_READ)
    mtx = fs.getNode("Camera_Matrix").mat()
    dist = fs.getNode("Distortion_Coefficients").mat()
    return mtx, dist