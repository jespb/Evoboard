# Evoboard: Geoboard-inspired Evolved Typefonts

If you like this project, please cite our paper (full entry available after April 7, 2024):

```
@InProceedings{evoboard,
author = {Batista, Jo{\~{a}}o E. and Garrow, Frase and Spairani, Carlo H. and Martins, Tiago,
title = {{Evoboard: Geoboard-inspired Evolved Typefonts}},
year = 2024,
}
```


How fit is your glyph? Towards the automatic evaluation of evolved letter designs

Notes about the Evoboard project:


We provide instructions to recreate on a unix based OS (if you have windows please alter 
accordingly). First create a Python environment to install the required dependencies. We 
recommend you use Python v3.10.4, ymmv with other versions.

```
python3 -m venv env
```

Then activate the environment and install the requirements.

```
source env/bin/activate
pip install -r requirements.txt
```

You should also have a working installation of Processing (we used v4.3) and tesseract.


To run an experiment, you should follow these steps:

```
1- Download either the EMNIST [1] or TMNIST [2] datasets

[1] https://www.kaggle.com/code/vishakkbhat/emnist-letter-dataset-97-9-acc-val-acc-91-78
[2] https://www.kaggle.com/datasets/nikbearbrown/tmnist-alphabet-94-characters

2- Add them to the respective directory, e.g., "Evoboard/OCR_Models/EMNIST/"

3- Run the Evoboard/OCR_Models/induceModel.py script (You may change it according to your needs)
   This script will generate a *.joblib file containing your trained OCR model

4- Move the *.joblib file to Evoboard/Evoboard/ocr_model/

5- Open the Evoboard/Evoboard/runProcessing.py file
   Change the "processing_dir" variable to your Processing directory
   Change the remaining input variables according to your need 

6- Run the runProcessing.py file
   This will open the Processing and you need to click [play] in it.
   This last step is somewhat bothersome and we intend to make a mode straightfoward approach eventually 
```

Additional nodes:

```
Rather than running the runProcessing.py files, you may run the main_evaluators.py directly for a single run:
-E.g., python3 main_evaluators.py A fixed_length OCR 0 EMNIST ocr_models/model.joblib rf

All OCR models are trained in a multi-class dataset. 
You only need to train them once and can use them on all characters.


```

