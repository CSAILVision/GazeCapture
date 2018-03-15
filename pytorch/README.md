# Eye Tracking for Everyone Pytorch re-implementation

## Introduction
This is a Pytorch re-implementation of the 2016 CVPR paper, "Eye Tracking for Everyone".

It is a simplified version without fine tuning and augmentations which may result to lower performance. It is provided for convenience without any guarantee. For original results please refer to the Caffe version of the code which was used for the CVPR 2016 submission.

* The combined test L2 error of the provided checkpoint is 2.46 cm. That is the display error distance in cm for both iPad and iPhone together.
* The format of dataset for the loader may differ from the dataset provided at http://gazecapture.csail.mit.edu . Please modify the data loader to fit your needs.

Implemented by Petr Kellnhofer ( https://people.csail.mit.edu/pkellnho/ ). Refer to the main repository https://github.com/CSAILVision/GazeCapture for more info.

## History
Any necessary changes to the dataset will be documented here.

* **March 2018**: Original code release.

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

## Code

Requires CUDA and Python 3+ with following packages (exact version may not be necessary):

* numpy (1.13.3)
* Pillow (4.3.0)
* torch (0.3.1.post2)
* torchfile (0.1.0)
* torchvision (0.2.0)
* scipy (0.19.0)


## Contact

Please email any questions or comments to [gazecapture@gmail.com](mailto:gazecapture@gmail.com).
