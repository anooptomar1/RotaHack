# Recognizing Images in an AR Experience

Detect known 2D images in the user's environment, and use their positions to place AR content.

## Overview

Many AR experiences can be enhanced by using known features of the user's environment to trigger the appearance of virtual content. For example, a museum app might show a virtual curator when the user points their device at a painting, or a board game might place virtual pieces when the player points their device at a game board. In iOS 11.3 and later, you can add such features to your AR experience by enabling image recognition in ARKit: Your app provides known 2D images, and ARKit tells you when and where those images are detected during an AR session.

This example app looks for any of the several reference images included in the app's asset catalog. When ARKit detects one of those images, the app shows a message identifying the detected image and a brief animation showing its position in the scene.

- Important: The images included with this sample are designed to fit the screen sizes of various Apple devices. To try the app using these images, choose an image that fits any spare device you have, and display the image full screen on that device. Then run the sample code project on a different device, and point its camera at the device displaying the image. Alternatively, you can add your own images; see the steps in Provide Your Own Reference Images, below.


## Getting Started

ARKit image detection and this sample app require iOS 11.3 and a device with an A9 (or later) processor. ARKit isn't available in iOS Simulator.

The code base is the source provided by Apple Image detection
