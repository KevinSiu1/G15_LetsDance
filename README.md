# G15_LetsDance

## Project Description
Let's Dance is an awesome dance video game based off of motion detection. It uses a video camera to capture dance movements and displays the video onto a montior in crisp HD resolution. Its processing power comes from a FPGA powered by a MicroBlaze core with custom logic for motion detection. A beautiful choreographed dance sequence is displayed on the screen for the player to follow. This game truly is fun for the whole family! :dancer:

## Instructions on How to Use
### Required Materials
- Nexys Video Board
- HDMI Video Camera
- Monitor

### Steps
1. Download the 'src' directory from this GitHub repo.
2. Open up the 'hdmi.xpr' file located under 'src/project' using Xilinx Vivado Design Suite (Disclaimer: This project was built and tested under the 2016.2 version, different versions may require additional effort).
3. Click on 'Generate Bitstream' to synthesize, implement and generate the bitstream for the project.
4. Export the hardware and the bitstream and launch the SDK.
5. Connect the FPGA to your computer. Click program FPGA and choose 'hdmi_wrapper_hw_platform_3'.
6. Connect the monitor to the HDMI_out of the Nexys Video board and the video camera to the HDMI_in of the board.
7. Run the program "test".
8. After the video loads, enter 'p' to play!
9. Have fun and enjoy! (FYI: Our best score was 17 - try to beat it!)

## Repository Structure
The repository is organized as follows:

src: This directory contains the project files and IP

	↪ ColorDetect2_1.0: This contains the files related to the Colour Detection IP

		↪ drivers/ColorDetect2_1.0: This contains software drivers for the IP block

		↪ hdl: This contains the top level Verilog wrapper and the AXI interface

		↪ src: This contains the colour detection core and stream interface files

	↪ MotionDeIP_1.0: This contains the files related to the Motion Detection IP

		↪ drivers/MotionDeIP_1.0: This contains software drivers for the IP block

		↪ hdl: This contains the code for the Verilog module

	↪ project: This contains the Vivado project files

		↪ hdmi.xpr: This is the main Vivado project file

		↪ hdmi.srcs/sources_1: This directory contains the source files for all the blocks
      used in the design

		↪ hdmi.sdk: This folder contains the software files

			↪ hdmi_wrapper_hw_platform_3: This contains the .bit file used to 
          program the FPGA

			↪ test: This directory contains the source code for the Let’s Dance game.

			↪ test_bsp: This contains the board support files

docs: This directory contains the documentation related to this project

	↪ ECE532_G15_Final_Report: This is the final report for the project (i.e. this file)

	↪ Final_Presentation.pdf: These are the slides used in the final demo

video: This directory contains a video of the game in action :)

	↪ video.mp4: Video showing the gameplay 

## Authors
This project was developed by Yinghui (Vivien) Fan, Yi Qing (Vicky) Li, and Kevin Siu for their ECE532 Project


## Acknowledgements
The authors would like to thank their TA Jin Hee for her feedback and support.
