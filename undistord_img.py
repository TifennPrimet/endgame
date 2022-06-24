import cv2 as cv
def undistord_img(img, mtx, dist):
    """"
    Function that calibrates the images  according to the distortion matrix you gave it
    Parameters
    ----------
    img : original image
    mtx : <class 'numpy.ndarray'>
        3x3 floating-point camera intrinsic matrix
    dist : <class 'numpy.ndarray'>
        vector of distortion coefficients
    """
    h, w = img.shape[:2]
    newcameramtx, roi = cv.getOptimalNewCameraMatrix(mtx, dist, (w,h), 1, (w,h))
    dst = cv.undistort(img, mtx, dist, None, newcameramtx)
#    crop the image
#    if roi != (0,0,0,0):        
#        x, y, w, h = roi
#        dst = dst[y:y+h, x:x+w]
    return dst