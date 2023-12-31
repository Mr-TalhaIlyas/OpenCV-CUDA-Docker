import numpy as np 
import cv2

frame1 = (cv2.imread('img.jpg', cv2.IMREAD_GRAYSCALE))
frame2 = (cv2.imread('img.jpg', cv2.IMREAD_GRAYSCALE))
print(frame1.shape)
nvof = cv2.cuda_NvidiaOpticalFlow_1_0.create((frame1.shape[1], frame1.shape[0]), 5, False, False, False, 3)

flow = nvof.calc(frame1, frame2, None)

flowUpSampled = nvof.upSampler(flow[0], frame1.shape[1], frame1.shape[0], nvof.getGridSize(), None)

cv2.writeOpticalFlow('OpticalFlow.flo', flowUpSampled)
nvof.collectGarbage()
print('Done.........')
