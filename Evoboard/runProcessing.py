
import os
import subprocess
#import pyautogui
#import time

this_script_dir = os.path.abspath(os.path.dirname(__file__))
processing_dir = "[path-to-processing]"

dataset = "TMNIST"
ocr_model = "ocr_models/RF_TMNIST_MD15_NEST20_9880_9241.joblib" # example
ocr_model_type = ["rf","cnn"][0] # rf: random forest, cnn: c. neural networks

for char in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ":
	for run in range(30):
		fixed_length = False

		if fixed_length:
			representation = "fixed_length"
			subprocess.run([
		 		f"{processing_dir}/processing-4.3/processing",
				f"{this_script_dir}/fixed_length/dots.pde"
				])
		else:
			representation = "variable_length"
			subprocess.run([
		 		"/home/jebatista/Desktop/BACKED/FCUL/2023/EvoMUSArt_2024/processing-4.3/processing",
				f"{this_script_dir}/variable_length/evoboard.pde"
				])

		fitness = ["OCR", "RMSE"][0]


		#
		#time.sleep(3)
		#x,y = pyautogui.position()
		#pyautogui.moveTo(676, 319)
		#pyautogui.click(676, 319)
		#pyautogui.moveTo(x,y)
		#pyautogui.click(x,y)

		print("Please click [start] on the processing window")
		print("This main will soon be updated so that this process is cleaner")


		subprocess.run([
			"python3",
			"main_evaluators.py",
			char,
			representation,
			fitness,
			"%d"%run,
			dataset,
			ocr_model,
			ocr_model_type
			])
