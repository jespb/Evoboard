import os, time, sys
from pathlib import Path
from PIL import Image, ImageOps
from sklearn.model_selection import train_test_split
import os
from joblib import dump, load
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import pandas as pd

this_script_dir = os.path.abspath(os.path.dirname(__file__))
parent_dir = Path(this_script_dir).parent.absolute
data_dir = os.path.join(this_script_dir, 'data')
model_dir = os.path.join(this_script_dir, 'models')


def inv_label_dict():
    chr_ords = [*range(48, 57+1)] + [*range(65, 90+1)]
    labels_to_chr_ords = dict(enumerate(chr_ords))
    return {v: k for k, v in labels_to_chr_ords.items()}

label_dict = inv_label_dict()

import warnings
warnings.filterwarnings("ignore",category=UserWarning)


def rmse_similarity(sample, target):
    """
    Return the similarity of the evolved image to a given target for based on 
    the RMSE.
    """
    
    rmse = 0
    max_rmse = 0

    for x in range(sample.width):
        for y in range(sample.height):
            rmse += ( sample.getpixel((x, y)) - target.getpixel((x, y)) )**2
            max_rmse += 1

    area = sample.width * sample.height
    
    rmse = ( rmse / area ) ** 0.5
    max_rmse = ( max_rmse / area ) ** 0.5

    norm = rmse / max_rmse
    return 1-norm

def predict(clf, model_type, x, target_label, isEMNIST):
    """
    Return the likelihood the evolved image resembles the given target for
    a classifier trained on the emnist dataset (a handwritten dataset of 
    alphanumeric characters).
    """

    if model_type=='cnn':
        x = np.expand_dims(x, axis=0)
        proba = clf.predict(x)[0][target_label]
    elif model_type=='rf':
        if isEMNIST: # EMNIST:
            x = x.flatten()
        else: #TMNIST
            x = 255 - x.flatten() # 255- for TMNIST
        target_label_index = list(clf.classes_).index(target_label) #TMNIST
        proba = clf.predict_proba([x])[0] 
        proba = proba[target_label_index]
    else:
        proba = 0.0
    
    return proba


import matplotlib.pyplot as plt

def fitness_RMSE(modelImgPath, targetImgPath):
    img1 = Image.open(modelImgPath).convert("L").resize((64,64))
    img2 = Image.open(targetImgPath).convert("L").resize((64,64))


    v1 = np.array(img1)
    v2 = np.array(img2)

    rmse = np.abs(v1-v2).mean()

    return 1 - rmse/255 



def get_target_label(target):
    return int(label_dict[ord(target)])



def evaluate_image(img_path : Path, target : chr, model, fitness_type, isEMNIST):
    model, model_type = model

    if fitness_type == "OCR":
        evolved_img = Image.open(img_path).convert("L")

        x = np.array(evolved_img.resize((28,28)))

        if isEMNIST:
            target_label = get_target_label(target) #EMNIST
        else:
            target_label = target #TMNIST

        fitness = predict(model, model_type, x, target_label, isEMNIST)

    else:
        filename = target + '.png'

        target_img_path = os.path.join(this_script_dir, 'data_rmse', filename)
        fitness = fitness_RMSE(img_path, target_img_path)
    
        

    return fitness

import subprocess

if __name__ == '__main__':
    try:
        print('Loading classifiers')
        target = sys.argv[1][0] # cmd line arg as chr
        representation_name = sys.argv[2]
        fitness_type = sys.argv[3]
        run = sys.argv[4]
        isEMNIST = sys.argv[5] == "EMNIST"
        model_filename = sys.argv[6]
        model_type = sys.argv[7] 

        model = load(model_filename), model_type 


        print('Target character: %s' % target)


        path_file_images_list = os.path.join(this_script_dir, representation_name, 'images_list.txt')
        path_file_images_fitness = os.path.join(this_script_dir, representation_name, 'images_fitness.txt')

        print(path_file_images_fitness)

        print('Waiting for images')
        gen = 0
        attempts = 0
        while attempts<20:
            attempts += 1
            if os.path.exists(path_file_images_list) and os.path.isfile(path_file_images_list):
                attempts = 0

                print('Evaluating images')
                with open(path_file_images_list) as f:
                    images_paths = [line.strip() for line in f]
      
                best_img = images_paths[0]
                best_fit = -9999
                images_fitness = []

                print(images_paths)

                #print(images_paths)
                for img_path in images_paths:
                    fit= evaluate_image(img_path, target, model, fitness_type, isEMNIST)
                    images_fitness.append(fit)
                    if fit > best_fit:
                        best_fit=fit
                        best_img = img_path

                subprocess.run(["mkdir", "%s/%s/%s/"%(representation_name, fitness_type, target)])
                subprocess.run(["mkdir", "%s/%s/%s/%s/"%(representation_name, fitness_type, target, run)])
                
                if representation_name == "variable_length":
                    n_dot = best_img.split("_")[-1].split(".")[0]
                    subprocess.run(["cp", best_img, "%s/%s/%s/%s/%s_%s_%d_%s_%.4f.png" %(representation_name, fitness_type, target,run, target, run, gen, n_dot, best_fit)])
                else:
                    subprocess.run(["cp", best_img, "%s/%s/%s/%s/%s_%s_%d_%.4f.png" %(representation_name, fitness_type, target,run, target, run, gen, best_fit)])


                assert not os.path.exists(path_file_images_fitness)
                with open(path_file_images_fitness, 'w') as f:
                    f.write('\n'.join([str(v) for v in images_fitness]))
                os.remove(path_file_images_list)
                print('Waiting for images')
                gen += 1
            time.sleep(0.5)
    except KeyboardInterrupt:
        pass