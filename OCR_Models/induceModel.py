from sklearn.ensemble import RandomForestClassifier
import pandas 
from matplotlib import pyplot as plt
import numpy as np
from joblib import load, dump
from sklearn.metrics import accuracy_score

from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

DATASET_DIR = "EMNIST/"
FILE_TRAIN  = "emnist-balanced-train.csv"
FILE_TEST   = "emnist-balanced-test.csv"

FILE_TMNIST = "94_character_TMNIST.csv"


def openAndSplitDatasets(filename):
	ds = pandas.read_csv(filename)

	class_header = ds.columns[1]
	Y = list(ds[class_header])


	return train_test_split(ds.drop(columns=ds.columns[:2]), ds[class_header], 
		train_size=0.7, random_state=42, stratify = ds[class_header])


def openAndCorrectDataset(filename):
	# Open dataset
	df = pandas.read_csv(filename, header=None)

	Y = df[df.columns[0]]
	X = df.drop(columns=df.columns[:1])

	samples = []
	for sample in X.iloc:
		sample = 255-np.array(sample)
		sample = sample.reshape(28,-1)
		sample = np.flip(sample, 0)
		sample = sample.flatten()
		samples.append(sample)

	X = pandas.DataFrame(samples, columns =["#%d"%x for x in range(len(X.columns))])
	
	return X,Y



def openDataset(filename):
	# Open dataset
	df = pandas.read_csv(filename)

	Y = df[df.columns[-1]]
	X = df.drop(columns=df.columns[-1:])

	return X,Y




correct_eminst = False
train_eminst = False
correct_tminst = False
train_tminst = False


if correct_eminst:
	print("Correcting EMNIST dataset")

	X_tr, Y_tr = openAndCorrectDataset(DATASET_DIR + FILE_TRAIN)
	X_te, Y_te = openAndCorrectDataset(DATASET_DIR + FILE_TEST)

	tmp = np.array(X_te.iloc[9]).reshape(28,-1)
	plt.imshow(tmp)
	plt.show()

	X_tr["Target"]=Y_tr
	X_te["Target"]=Y_te

	X_tr.to_csv(DATASET_DIR+"corrected_"+FILE_TRAIN, index=False)
	X_te.to_csv(DATASET_DIR+"corrected_"+FILE_TEST , index=False)



if train_eminst:
	print("Training model using EMNIST dataset")

	max_depth = 15
	n_estimators = 10

	X_tr, Y_tr = openDataset(DATASET_DIR + "corrected_" + FILE_TRAIN)
	X_te, Y_te = openDataset(DATASET_DIR + "corrected_" + FILE_TEST)

	model = RandomForestClassifier(max_depth=max_depth, random_state=42, n_estimators=n_estimators)
	model.fit(X_tr, Y_tr)

	acc_tr = accuracy_score( model.predict(X_tr), Y_tr)
	acc_te = accuracy_score( model.predict(X_te), Y_te)

	print(acc_tr, acc_te)

	dump(model, "RF_EMNIST_MD%d_NEST%d.joblib" % (max_depth, n_estimators))



if correct_tminst:
	print("Correcting TMNIST dataset")
	X_tr, X_te, Y_tr, Y_te = openAndSplitDatasets("TMNIST/" + FILE_TMNIST)

	X_tr["Target"]=Y_tr
	X_te["Target"]=Y_te

	X_tr.to_csv("TMNIST/corrected_full_train_"+FILE_TMNIST, index=False)
	X_te.to_csv("TMNIST/corrected_full_test_" +FILE_TMNIST , index=False)



if train_tminst:
	print("Training model using TMNIST dataset")

	max_depth = 15
	n_estimators = 50

	X_tr, Y_tr = openDataset("TMNIST/corrected_full_train_"+FILE_TMNIST)
	X_te, Y_te = openDataset("TMNIST/corrected_full_test_" +FILE_TMNIST)

	model = RandomForestClassifier(max_depth=max_depth, random_state=42, n_estimators=n_estimators)
	model.fit(X_tr, Y_tr)

	acc_tr = accuracy_score( model.predict(X_tr), Y_tr)
	acc_te = accuracy_score( model.predict(X_te), Y_te)

	print(acc_tr, acc_te)

	dump(model, "RF_TMNIST_full_MD%d_NEST%d.joblib" % (max_depth, n_estimators))


