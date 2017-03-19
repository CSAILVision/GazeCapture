# Eye Tracking for Everyone Code, Dataset and Models

## Introduction
This is the README file for the official code, dataset and model release associated with the 2016 CVPR paper, "Eye Tracking for Everyone".

The dataset release is broken up into three parts:

* **Data** (image files and associated metadata)
* **Models** (Caffe model definitions)
* **Code** (some essential scripts to make use of the data)

Continue reading for more information on each part.

## History
Any necessary changes to the dataset will be documented here.

* **March 2017**: Original code, dataset and models released.

## Usage
Usage of this dataset (including all data, models, and code) is subject to the associated license, found in [LICENSE.md](LICENSE.md). The license permits the use of released code, dataset and models for research purposes only.

We also ask that you cite the associated paper if you make use of this dataset; following is the BibTeX entry:

```
@inproceedings{cvpr2016_gazecapture,
Author = {Kyle Krafka and Aditya Khosla and Petr Kellnhofer and Harini Kannan and Suchendra Bhandarkar and Wojciech Matusik and Antonio Torralba},
Title = {Eye Tracking for Everyone},
Year = {2016},
Booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)}
}
```

## Data
The dataset can be downloaded at the [project website](http://gazecapture.csail.mit.edu/download.php). In the dataset, we include data for 1474 unique subjects. Each numbered directory represents a recording session from one of those subjects. Numbers were assigned sequentially, although some numbers are missing for various reasons (e.g., test recordings, duplicate subjects, or incomplete uploads).

Inside each directory is a collection of sequentially-numbered images (in the `frames` subdirectory) and JSON files for different pieces of metadata, described below. Many of the variables in the JSON files are arrays, where each element is associated with the frame numbered the same as the index.

In training our iTracker model, we only made use of frames where the subject's device was able to detect both the user's [face](https://developer.apple.com/reference/avfoundation/avcapturemetadataoutputobjectsdelegate) and [eyes](https://developer.apple.com/reference/coreimage/cidetector) using Apple's built-in libraries. Some subjects had *no* frames with face and eye detections at all. There are 2,445,504 total frames and 1,490,959 with complete Apple detections. For this reason, some frames will be "missing" generated data.

The dataset is split into three pieces, by subject (i.e., recording number): training, validation, and test.

Following is a description of each variable:

### appleFace.json, appleLeftEye.json, appleRightEye.json
These files describe bounding boxes around the detected face and eyes, logged at recording time using Apple libraries. "Left eye" refers to the subject's physical left eye, which appears on the right side of the image.

- `X`, `Y`: Position of the top-left corner of the bounding box (in pixels). In `appleFace.json`, this value is relative to the top-left corner of the full frame; in `appleLeftEye.json` and `appleRightEye.json`, it is relative to the top-left corner of the *face crop*.
- `W`, `H`: Width and height of the bounding box (in pixels).
- `IsValid`: Whether or not there was actually a detection. 1 = detection; 0 = no detection.

### dotInfo.json
- `DotNum`: Sequence number of the dot (starting from 0) being displayed during that frame.
- `XPts`, `YPts`: Position of the center of the dot (in points; see `screen.json` documentation below for more information on this unit) from the top-left corner of the screen.
- `XCam`, `YCam`: Position of the center of the dot in our prediction space. The position is measured in centimeters and is relative to the camera center, assuming the camera remains in a fixed position in space across all device orientations. I.e., `YCam` values will be negative for portrait mode frames (`Orientation` == 1) since the screen is below the camera, but values will be positive in upside-down portrait mode (`Orientation` == 2) since the screen is above the camera. See Section 4.1 and Figure 6 for more information.
- `Time`: Time (in seconds) since the displayed dot first appeared on the screen.

### faceGrid.json
These values describe the "face grid" input features, which were generated from the Apple face detections. Within a 25 x 25 grid of 0 values, these parameters describe where to draw in a box of 1 values to represent the position and size of the face within the frame.

- `X`, `Y`: Position of the top-left corner of the face box (1-indexed, within a 25 x 25 grid).
- `W`, `H`: Width and height of the face box.
- `IsValid`: Whether the data is valid (1) or not (0). This is equivalent to the intersection of the associated `IsValid` arrays in the apple*.json files (since we required samples to have Apple face and eye detections).

### frames.json
The filenames of the frames in the `frames` directory. This information may also be generated from a sequence number counting from 0 to `TotalFrames` - 1 (see `info.json`).

### info.json
- `TotalFrames`: The total number of frames for this subject.
- `NumFaceDetections`: The number of frames in which a face was detected.
- `NumEyeDetections`: The number of frames in which eyes were detected.
- `Dataset`: "train," "val," or "test."
- `DeviceName`: The name of the device used in the recording.

### motion.json
A stream of motion data (accelerometer, gyroscope, and magnetometer) recorded at 60 Hz, only while frames were being recorded. See Apple's [CMDeviceMotion](https://developer.apple.com/reference/coremotion/cmdevicemotion) class for a description of the values. `DotNum` (counting from 0) and `Time` (in seconds, from the beginning of that dot's recording) are recorded as well.

### screen.json
- `H`, `W`: Height and width of the active screen area of the app (in points). This allows us to account for the iOS "Display Zoom" feature (which was used by some subjects) as well as larger status bars (e.g., when a Personal Hotspot is enabled) and split screen views (which was not used by any subjects). See [this](https://developer.apple.com/library/content/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/GraphicsDrawingOverview/GraphicsDrawingOverview.html) and [this](https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions) page for more information on the unit "points."
- `Orientation`: The orientation of the interface, as described by the enumeration [UIInterfaceOrientation](https://developer.apple.com/reference/uikit/uiinterfaceorientation), where:
  - 1: portrait
  - 2: portrait, upside down (iPad only)
  - 3: landscape, with home button on the right
  - 4: landscape, with home button on the left

## Models
In the `models` directory, we provide files compatible with [Caffe](http://caffe.berkeleyvision.org/), the deep learning framework. Following are descriptions of the included files:

- *itracker_train_val.prototxt*: The iTracker architecture. See comments in the file for more information.
- *itracker_deploy.prototxt*: The iTracker architecture expressed in a format suitable for inference (whereas itracker_train_val.prototxt is used for training).
- *itracker_solver.prototxt*: The solver configuration describing how to train the model.
- *mean_images/*: Directory containing 224x224 mean images (in Caffe binaryproto format and MATLAB mat format). These were produced by averaging all training images for each of the left eye, right eye, and face images.
- *snapshots/itracker_iter_92000.caffemodel*: Model parameters after having trained 92,000 iterations, using the original dataset.
- *snapshots/itracker25x_iter_92000.caffemodel*: Model parameters after having trained 92,000 iterations, using the 25x augmented dataset.

## Code
We provide some sample code to help you get started using the dataset. Below is a high-level overview, but see individual files for more documentation. Most files are MATLAB scripts/functions.

- `loadSubject.m`, `loadAllSubjects.m`: Loads metadata from JSON files into MATLAB structs. This requires the [gason MATLAB wrapper](https://github.com/pdollar/coco/tree/master/MatlabAPI) to parse JSON. Note that this struct format is currently only used in a few scripts; others expect same-sized vectors for each piece of metadata and will require some data processing.
- `generateCrops.m`: This will generate the cropped face and eye images required to train iTracker. You must edit the script path to point to the root of the dataset. New images will be saved in subdirectories under each subject.
- `cropRepeatingEdge.m`: Crops an image, repeating edges if the cropped area goes outside of the original image bounds. (Face bounding boxes sometimes extend beyond the frame.) We use this script to mimic the behavior of [imageByClampingToExtent](https://developer.apple.com/reference/coreimage/ciimage/1437628-imagebyclampingtoextent), which we used in the GazeCapture app, and to provide something more natural than black pixels when training the network with fixed-size centered face images.
- `cam2screen.m`, `screen2cam.m`, `cm2pts.m`, `pts2cm.m`: Transformation functions to move between iOS measurements (points), metric measurements (centimeters), and our prediction space. Measurements in the GazeCapture dataset are already included in different formats, but these will be useful for additional processing.
- `apple_device_data.csv`, `loadAppleDeviceData.m`: The CSV file includes measurements we use to determine the position of the center of the camera relative to the screen. We derived these measurements from Apple's Device Dimensional Drawings in their [Accessory Design Guidelines (PDF)](https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf). The script can be used to load this CSV into your MATLAB workspace.
- `faceGridFromParams.m`: Transform the compact, parameterized version of the face grid (included in metadata) into the actual feature representation (flattened binary mask) used in iTracker.
- `faceGridFromFaceRect.m`: Generate a face grid (either parameterized or the full representation) given a face bounding box within a frame. Parameterized face grids are already included in the metadata, but this is useful if you have new face detections to use.

Please feel free to contact us if you find any issues with these scripts or would like to request any additional code.

## Contact

Please email any questions or comments to [gazecapture@gmail.com](mailto:gazecapture@gmail.com).
