import zipfile
import glob 
import os
def unzip(folder ) :
    """" Function that unzip all the files in a folder
    Parameters :
    ----------
    folder : string
        name of the path to the folder 
    Returns :
    ---------
    None
    """
    FILES = glob.glob(folder +'\*' + '.zip')
    
    for file in FILES :
        with zipfile.ZipFile(file,"r") as zip_ref:
            if not os.path.exists(folder + '_unziped'):
                os.makedirs(folder + '_unziped')
            zip_ref.extractall(folder + '_unziped' +file[len(folder):-len("_116_img_imgraw.tiff")])
    print("Dézippé !!!")

unzip("C:/Users/tprimet/Documents/REPRISE/MS/MS2")
