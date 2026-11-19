# Lab 10: Teachable Machine Image Classifier

## Part 1: Model & Classes

### 1. Six Classes Chosen (Finger Count & Gesture)
Since we are in the lab classroom with no external physical objects, we use finger counts / hand poses captured via webcam:
1. One Finger (index finger up)
2. Two Fingers (peace / V sign)
3. Three Fingers
4. Four Fingers
5. Five Fingers (open palm)
6. Background (empty camera view / no hand in frame)

### 2. Part 1 Questions & Answers

**Q1: What does the model answer when it sees an object that belongs to none of your classes? How does the background class change that?**
Answer: The model outputs probabilities via a softmax layer, meaning the sum of all class probabilities must equal 100%. When an unfamiliar object or pose is shown, the model cannot return "unknown" or zero — it is forced to distribute probabilities across the 6 existing classes, giving high confidence to whichever finger count looks visually most similar in shape or outline.
Having an explicit "Background" class (empty frame without any hand) gives the model a dedicated bucket when no hand is raised. This avoids false positives where an empty room or desk is misclassified as one of the finger counts.

**Q2: The export dialog offers Floating point and Quantized. What differs between the two files in size, in input type and in what your Dart code would have to do?**
Answer:
- File size: Floating point uses 32-bit floats (`float32`), resulting in a ~4x larger file size. Quantized compresses the weights to 8-bit integers (`uint8`), reducing file size by ~75%.
- Input type: Floating point expects normalized float values in the range [-1.0, 1.0]. Quantized expects raw integer bytes in the range [0, 255].
- Dart code difference: For floating point, our Dart pre-processing must normalize each pixel value with `(pixel / 127.5) - 1.0`. For quantized, Dart passes raw byte integers directly without floating-point math, and normalizes the output values by dividing by 255.
