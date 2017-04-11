/*
 *  LET'S DANCE GAME SOFTWARE
 *
 */

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */
#include "video_demo.h"
#include "video_capture/video_capture.h"
#include "display_ctrl/display_ctrl.h"
#include "intc/intc.h"
#include <stdio.h>
#include <stdbool.h>
#include "xuartlite_l.h"
#include "math.h"
#include <ctype.h>
#include <stdlib.h>
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xosd.h"

#include "../../hdmi_wrapper_hw_platform_3/drivers/ColorDetect2_v1_0/src/ColorDetect2.h"
#include "../../hdmi_wrapper_hw_platform_3/drivers/MotionDeIP_v1_0/src/MotionDeIP.h"

/*
 * XPAR redefines
 */
#define DYNCLK_BASEADDR XPAR_AXI_DYNCLK_0_BASEADDR
#define VGA_VDMA_ID XPAR_AXIVDMA_0_DEVICE_ID
#define DISP_VTC_ID XPAR_VTC_0_DEVICE_ID
#define VID_VTC_ID XPAR_VTC_1_DEVICE_ID
#define VID_GPIO_ID XPAR_AXI_GPIO_VIDEO_DEVICE_ID
#define VID_VTC_IRPT_ID XPAR_INTC_0_VTC_1_VEC_ID
#define VID_GPIO_IRPT_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define SCU_TIMER_ID XPAR_AXI_TIMER_0_DEVICE_ID
#define UART_BASEADDR XPAR_UARTLITE_0_BASEADDR


/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

/*
 * Display and Video Driver structs
 */
DisplayCtrl dispCtrl;
XAxiVdma vdma;
VideoCapture videoCapt;
INTC intc;
char fRefresh; //flag used to trigger a refresh of the Menu on video detect

/*
 * Framebuffers for video data
 */
u8 frameBuf[DISPLAY_NUM_FRAMES][DEMO_MAX_FRAME];
u8 *pFrames[DISPLAY_NUM_FRAMES]; //array of pointers to the frame buffers

/*
 * Interrupt vector table
 */
const ivt_t ivt[] = {
	videoGpioIvt(VID_GPIO_IRPT_ID, &videoCapt),
	videoVtcIvt(VID_VTC_IRPT_ID, &(videoCapt.vtc))
};

/* ------------------------------------------------------------ */
/*				Main Function									*/
/* ------------------------------------------------------------ */
int main(void) {

	char userInput = 0;
	u32 locked;
	XGpio *GpioPtr = &videoCapt.gpio;
	int score = 0;
	int high_score = 0;
	int i = 0;

	XOsd xosd_inst;
	XOsd_Config *xosd_cfg;

	u32 ColorData[16];
	u32 TextData[64];
	u32 InstSetPtr[32]; //TODO: Max 8 instructions?

	Xil_ICacheEnable();
	Xil_DCacheEnable();
	DemoInitialize();	//Set up VDMA driver, display controller, interrupt controller, and the video capture

	//Set up the video OSD
	xosd_cfg = XOsd_LookupConfig(XPAR_OSD_0_DEVICE_ID);
	if (XOsd_CfgInitialize(&xosd_inst, xosd_cfg, XPAR_OSD_0_BASEADDR) != XST_SUCCESS)
		xil_printf("XOsd_CfgInitialize FAILED\r\n");
	if (XOsd_SelfTest(&xosd_inst) != XST_SUCCESS)
		xil_printf("XOsd_SelfTest FAILED\r\n");

	//Reset and Enable Register Updates
	XOsd_Reset(&xosd_inst);
	XOsd_SyncReset(&xosd_inst);
	XOsd_RegUpdateEnable(&xosd_inst);
	XOsd_Start(&xosd_inst);

	//Disable Base (Video) Layer
	XOsd_DisableLayer(&xosd_inst, 0);

	//Set Background Color to Black
	XOsd_SetBackgroundColor(&xosd_inst, 0, 0, 0);

	(&xosd_inst)->ScreenWidth = 0x500;
	(&xosd_inst)->ScreenHeight = 0X2D0;
	XOsd_SetLayerDimension(&xosd_inst, 0, 0, 0, 0x500, 0x2D0);
	XOsd_SetLayerDimension(&xosd_inst, 1, 0, 0, 0x500, 0x2D0);

	//Set Active Bank and Enable Layer
	XOsd_SetActiveBank(&xosd_inst, 1, 1, 1, 1, 1);
	XOsd_EnableLayer(&xosd_inst, 1);

	//Initialize Colour Banks of OSD
	ColorData[0] = 0x00000000;	//Black (Background Colour)
	ColorData[1] = 0x00000000;
	ColorData[2] = 0xffff0000;	//Red
	ColorData[3] = 0x00000000;
	ColorData[4] = 0xff0000ff;	//Green
	ColorData[5] = 0x00000000;
	ColorData[6] = 0xff00ff00;	//Blue
	ColorData[7] = 0x00000000;
	ColorData[8] = 0xffffffff;	//White
	ColorData[9] = 0x80000000;
	ColorData[10] = 0xffff00ff;	//Yellow
	ColorData[11] = 0x00000000;
	ColorData[12] = 0xffffff00; //Purple
	ColorData[13] = 0x00000000;

	//Unused
	ColorData[14] = 0x00000000;
	ColorData[15] = 0x00000000;


	//Initialize Text String and Character Banks
	for (i = 0; i < 64; i++)
		TextData[i] = 0x00000000;
	for (i = 0; i < 32; i++)
		InstSetPtr[i] = 0x00000000;

	XOsd_LoadColorLUTBank(&xosd_inst, 1, 1, ColorData);
	XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);

	/*
	 *  Loading screen until video is successfully connected
	 *  Loading screen is just black, with LOADING ... (dots should have loading pattern)
	 */

	//Text Strings
	TextData[0] = 0x05030201; //Loading
	TextData[1] = 0x00090706;
	TextData[8] = 0x00000000; //Dots
	TextData[9] = 0x00000000;

	//Character Encodings
	TextData[2] = 0x30303000; //L
	TextData[3] = 0x003e3030;
	TextData[4] = 0x66663c00; //O
	TextData[5] = 0x003c6666;
	TextData[6] = 0x663c1800; //A
	TextData[7] = 0x00667e66;
	TextData[10] = 0x66667c00; //D
	TextData[11] = 0x007c6666;
	TextData[12] = 0x18187e00; //I
	TextData[13] = 0x007e1818;
	TextData[14] = 0x76766600; //N
	TextData[15] = 0x00666e6e;
	TextData[18] = 0x60603c00; //G
	TextData[19] = 0x003c6666;
	TextData[20] = 0x00000000; //DOT
	TextData[21] = 0x00181800;

	//Instructions
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x180, 0x140, 0x340, 0x140, 0x0, 0x8); //Loading Text
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+4, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x340, 0x140, 0x4ff, 0x140, 0x1, 0x8); //Dots

	XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
	XOsd_LoadInstructionList(&xosd_inst, 1, 1, InstSetPtr, 2);

	//Check if video is started, if so enable layer and display TITLE SCREEN
	while (VideoStart(&videoCapt) != XST_SUCCESS) {

		//Loading Screen Dot animation
		MB_Sleep(1000);
		TextData[8] = 0x0000000a;
		XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
		MB_Sleep(1000);
		TextData[8] = 0x00000a0a;
		XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
		MB_Sleep(1000);
		TextData[8] = 0x000a0a0a;
		XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
		MB_Sleep(1000);
		TextData[8] = 0x00000000;
		XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);

	}

	//TITLE SCREEN shows (semi-transparent light grey background - draw a box)
	/*
	 * 		LET'S DANCE!
	 *
	 * 		P-PLAY
	 * 		Q-QUIT
	 *
	 * 		HIGH SCORE:	00
	 */

	TITLE_SCREEN:

	//Text Strings
	TextData[0] = 0x05030201; //LET'S
	TextData[1] = 0x00000006;
	TextData[8] = 0x0b0a0907; //DANCE!
	TextData[9] = 0x00000d02;
	TextData[16] = 0x010e0f0e; //P-PLAY
	TextData[17] = 0x00001109;
	TextData[24] = 0x13120f12; //Q-QUIT
	TextData[25] = 0x00000315;
	TextData[32] = 0x16171516; //HIGH
	TextData[33] = 0x00000000;
	TextData[40] = 0x1a190b06; //SCORE
	TextData[41] = 0x00000002;
	TextData[48] = 0x00001d1b; //Score value
	TextData[49] = 0x00000000;

	//Characters
	TextData[2] = 0x30303000; //L
	TextData[3] = 0x003e3030;
	TextData[4] = 0x7c603e00; //E
	TextData[5] = 0x003e6060;
	TextData[6] = 0x18187e00; //T
	TextData[7] = 0x00181818;
	TextData[10] = 0x00181800; //'
	TextData[11] = 0x00000000;
	TextData[12] = 0x7e603e00; //S
	TextData[13] = 0x007c0606;
	TextData[14] = 0x66667c00; //D
	TextData[15] = 0x007c6666;
	TextData[18] = 0x663c1800; //A
	TextData[19] = 0x00667e66;
	TextData[20] = 0x76766600; //N
	TextData[21] = 0x00666e6e;
	TextData[22] = 0x60603e00; //C
	TextData[23] = 0x003e6060;
	TextData[26] = 0x60606000; //!
	TextData[27] = 0x00600060;
	TextData[28] = 0x66667c00; //P
	TextData[29] = 0x0060607e;
	TextData[30] = 0x3c000000; //-
	TextData[31] = 0x00000000;
	TextData[34] = 0x66666600; //Y
	TextData[35] = 0x007e063e;
	TextData[36] = 0x66663c00; //Q
	TextData[37] = 0x063c6e66;
	TextData[38] = 0x66666600; //U
	TextData[39] = 0x003c6666;
	TextData[42] = 0x18187e00; //I
	TextData[43] = 0x007e1818;
	TextData[44] = 0x7e666600; //H
	TextData[45] = 0x00666666;
	TextData[46] = 0x60603c00; //G
	TextData[47] = 0x003c6666;
	TextData[50] = 0x66663c00; //O/0
	TextData[51] = 0x003c6666;
	TextData[52] = 0x7c663c00; //R
	TextData[53] = 0x00666c78;

	switch (high_score)
	{
	case  0:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x66663c00; TextData[59] = 0x003c6666; break;
	case  1:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x0c0c1800; TextData[59] = 0x001e0c0c; break;
	case  2:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x7c067c00; TextData[59] = 0x007e6060; break;
	case  3:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x3c067c00; TextData[59] = 0x007c0606; break;
	case  4:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x66666600; TextData[59] = 0x0006063e; break;
	case  5:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x7c607e00; TextData[59] = 0x007c0606; break;
	case  6:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x7c603e00; TextData[59] = 0x007c6666; break;
	case  7:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x06667c00; TextData[59] = 0x00060606; break;
	case  8:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x3c663c00; TextData[59] = 0x003c6666; break;
	case  9:	TextData[54] = 0x66663c00; TextData[55] = 0x003c6666; TextData[58] = 0x3e663c00; TextData[59] = 0x007c0606; break;
	case  10:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x66663c00; TextData[59] = 0x003c6666; break;
	case  11:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x0c0c1800; TextData[59] = 0x001e0c0c; break;
	case  12:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x7c067c00; TextData[59] = 0x007e6060; break;
	case  13:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x3c067c00; TextData[59] = 0x007c0606; break;
	case  14:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x66666600; TextData[59] = 0x0006063e; break;
	case  15:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x7c607e00; TextData[59] = 0x007c0606; break;
	case  16:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x7c603e00; TextData[59] = 0x007c6666; break;
	case  17:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x06667c00; TextData[59] = 0x00060606; break;
	case  18:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x3c663c00; TextData[59] = 0x003c6666; break;
	case  19:	TextData[54] = 0x0c0c1800; TextData[55] = 0x001e0c0c; TextData[58] = 0x3e663c00; TextData[59] = 0x007c0606; break;
	case  20:	TextData[54] = 0x7c067c00; TextData[55] = 0x007e6060; TextData[58] = 0x66663c00; TextData[59] = 0x003c6666; break;
	}

	//Instructions
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr, 1, XOSD_INS_OPCODE_BOX, 0, 0x10, 0x010, 0x4f0, 0x2c0, 0, 0x9);
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+4, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x100, 0x40, 0x280, 0x40, 0x0, 0xa); //LET'S TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+8, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x280, 0x40, 0x4ff, 0x40, 0x1, 0x2); //DANCE! TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+12, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x1e0, 0x100, 0x4ff, 0x100, 0x2, 0x6); //P-PLAY TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+16, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x1e0, 0x140, 0x4ff, 0x140, 0x3, 0xc); //Q-QUIT TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+20, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x100, 0x200, 0x240, 0x200, 0x4, 0x8); //HIGH TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+24, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x240, 0x200, 0x3c0, 0x200, 0x5, 0x8); //SCORE TEXT
	XOsd_CreateInstruction(&xosd_inst, InstSetPtr+28, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x3c0, 0x200, 0x4ff, 0x200, 0x6, 0x4); //SCORE VALUE

	//Draw Title Screen
	XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
	XOsd_LoadInstructionList(&xosd_inst, 1, 1, InstSetPtr, 8);

	while (!XUartLite_IsReceiveEmpty(UART_BASEADDR))
	{
		XUartLite_ReadReg(UART_BASEADDR, XUL_RX_FIFO_OFFSET);
	}

	while (userInput != 'q')
	{
		fRefresh = 0;

		while (XUartLite_IsReceiveEmpty(UART_BASEADDR) && !fRefresh)
		{}

		if (!XUartLite_IsReceiveEmpty(UART_BASEADDR))
		{
			userInput = XUartLite_ReadReg(UART_BASEADDR, XUL_RX_FIFO_OFFSET);
			xil_printf("%c", userInput);
		}
		else  //Refresh triggered by video detect interrupt
		{
			userInput = 'r';
		}

		switch (userInput)
		{

		case 'p':

			XOsd_EnableLayer(&xosd_inst, 0);

			//Set Instruction/Text Banks for Countdown
			TextData[0] = 0x00030201; //3 ... 2 ... 1 ... GO!
			TextData[1] = 0x00000000;

			TextData[2] = 0x3c067c00; //3
			TextData[3] = 0x007c0606;
			TextData[4] = 0x00000000; //BLANK
			TextData[5] = 0x00000000;
			TextData[6] = 0x00000000; //BLANK
			TextData[7] = 0x00000000;

			XOsd_CreateInstruction(&xosd_inst, InstSetPtr, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x240, 0x140, 0x340, 0x140, 0x0, 0x8); //Loading Text

			XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
			XOsd_LoadInstructionList(&xosd_inst, 1, 1, InstSetPtr, 1);

			//Countdown: 3, 2, 1, GO
			MB_Sleep(1500);
			TextData[2] = 0x7c067c00; //2
			TextData[3] = 0x007e6060;
			XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
			MB_Sleep(1500);
			TextData[2] = 0x0c0c1800; //1
			TextData[3] = 0x001e0c0c;
			XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
			MB_Sleep(1500);
			TextData[2] = 0x60603c00; //G
			TextData[3] = 0x003c6666;
			TextData[4] = 0x66663c00; //O/0
			TextData[5] = 0x003c6666;
			TextData[6] = 0x60606000; //!
			TextData[7] = 0x00600060;
			XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
			MB_Sleep(1500);


			//Text Strings
			TextData[0] = 0x05030201; //SCORE Text
			TextData[1] = 0x00000006;
			TextData[8] = 0x00000907; //SCORE Value
			TextData[9] = 0x00000000;

			//Text Characters
			TextData[2] = 0x7e603e00; //S
			TextData[3] = 0x007c0606;
			TextData[4] = 0x60603e00; //C
			TextData[5] = 0x003e6060;
			TextData[6] = 0x66663c00; //O
			TextData[7] = 0x003c6666;
			TextData[10] = 0x7c663c00; //R
			TextData[11] = 0x00666c78;
			TextData[12] = 0x7c603e00; //E
			TextData[13] = 0x003e6060;

			TextData[14] = 0x66663c00; //0
			TextData[15] = 0x003c6666;
			TextData[18] = 0x66663c00; //0
			TextData[19] = 0x003c6666;

			//Instructions
			XOsd_CreateInstruction(&xosd_inst, InstSetPtr, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x2ff, 0x28f, 0x4ff, 0x28f, 0x0, 0x8); //Score Text
			XOsd_CreateInstruction(&xosd_inst, InstSetPtr+4, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x47f, 0x28f, 0x4ff, 0x28f, 0x1, 0x8); //Score Value

			//Arrows (Strings)
			TextData[16] = 0x00000000;
			TextData[17] = 0x00000000;
			TextData[24] = 0x00000000;
			TextData[25] = 0x00000000;
			TextData[32] = 0x00000000;
			TextData[33] = 0x00000000;
			TextData[40] = 0x00000000;
			TextData[41] = 0x00000000;

			//Arrows (Chars)
			TextData[20] = 0x7f30180c; //Left Arrow
			TextData[21] = 0x0c18307f;
			TextData[22] = 0xff000000; //Arrow Tail (Horizontal)
			TextData[23] = 0x000000ff;
			TextData[26] = 0x7e3c1800; //Up Arrow
			TextData[27] = 0x181818db;
			TextData[28] = 0xdb181818; //Down Arrow
			TextData[29] = 0x00183c7e;
			TextData[30] = 0x18181818; //Arrow Tail (Vertical)
			TextData[31] = 0x18181818;
			TextData[34] = 0xfe0c1830; //Right Arrow
			TextData[35] = 0x30180cfe;

			// (vertical) down-right arrow
			TextData[36]  = 0x180c0602; // top half
			TextData[37]  = 0x40602030;
			TextData[38] = 0x31206040; // bottom half
			TextData[39] = 0x3f070d19;

			// (vertical) down-left arrow
			TextData[42] = 0x18306040; // top half
			TextData[43] = 0x0206040c;
			TextData[44] = 0x80060602; // bottom half
			TextData[45] = 0xfce0b098;

			// (horizontal) up-right arrow
			TextData[46] = 0x180e0300; // left half
			TextData[47] = 0x00c06030;
			TextData[50] = 0x1971c000; // right half
			TextData[51] = 0x1f03070d;

			// (horizontal) up-left arrow
			TextData[52] = 0x988e0300; // left half
			TextData[53] = 0xb0e0c0f8;
			TextData[54] = 0x1870c000; // right half
			TextData[55] = 0x0003060c;

			//Array containing dance moves
			u32 dance_moves[34] = {
					0x0000000b,
					0x00000015,
					0x00110015,
					0x0011000b,
					0x0000000b,		//5
					0x00000015,
					0x00110015,
					0x0011000b,
					0x0002000f,
					0x00050017,		//10
					0x00120011,
					0x00170009,
					0x0002000f,
					0x00050017,
					0x00120011,		//15
					0x00170009,
					0x0002000f,
					0x0011001f,
					0x0088001f,
					0x0090001d,		//20
					0x00210005,
					0x00000001,
					0x00990001,
					0x00810003,
					0x0022001f,		//25
					0x0033001f,
					0x00010005,
					0x00110001,
					0x00010003,
					0x00220001,		//30
					0x00330001,
					0x0010001b,
					0x0000001f,
					0x0010001d
			};

			u8 colour1 = 0;
			u8 colour2 = 0;
			u16 x1 = 0;
			u16 y1 = 0;
			u16 x2 = 0;
			u16 y2 = 0;

			//Set the number of frames to wait before sending coordinates
			COLORDETECT2_mWriteReg(XPAR_COLORDETECT2_0_S00_AXI_BASEADDR, COLORDETECT2_S00_AXI_SLV_REG0_OFFSET, 0x00000008);

			score = 0;

			for (i = 0; i < 34; i++) {

				//Determine Colour 1
				switch((dance_moves[i] >> 1) & 0x3) {
				case 0: //Red
					colour1 = 0x2;
					x1 = 0x320;
					y1 = 0xf0;
					break;
				case 1: //Green
					colour1 = 0x4;
					x1 = 0x320;
					y1 = 0x240;
					break;
				case 2: //Blue
					colour1 = 0x6;
					x1 = 0x1a9;
					y1 = 0x240;
					break;
				case 3: //Yellow
					colour1 = 0xa;
					x1 = 0x1a9;
					y1 = 0xf0;
					break;
				}

				//Determine Colour 2
				switch((dance_moves[i] >> 3) & 0x3) {
				case 0: //Red
					colour2 = 0x2;
					x2 = 0x320;
					y2 = 0xf0;
					break;
				case 1: //Green
					colour2 = 0x4;
					x2 = 0x320;
					y2 = 0x240;
					break;
				case 2: //Blue
					colour2 = 0x6;
					x2 = 0x1a9;
					y2 = 0x240;
					break;
				case 3: //Yellow
					colour2 = 0xa;
					x2 = 0x1a9;
					y2 = 0xf0;
					break;
				}

				//Determine Movement 1
				switch((dance_moves[i] >> 16) & 0xf) {
				case 0: //Right
					TextData[16] = 0x0000110b;
					TextData[24] = 0x00000000;
					break;
				case 1: //Left
					TextData[16] = 0x00000b0a;
					TextData[24] = 0x00000000;
					break;
				case 2: //Up
					TextData[16] = 0x0000000d;
					TextData[24] = 0x0000000f;
					break;
				case 3: //Down
					TextData[16] = 0x0000000f;
					TextData[24] = 0x0000000e;
					break;
				case 5: //Arc Down Right
					TextData[16] = 0x00000012;
					TextData[24] = 0x00000013;
					break;
				case 7: //Arc Down Left
					TextData[16] = 0x00000015;
					TextData[24] = 0x00000016;
					break;
				case 8: //Arc Top Right
					TextData[16] = 0x00001917;
					TextData[24] = 0x00000000;
					break;
				case 9: //Arc Top Right
					TextData[16] = 0x00001b1a;
					TextData[24] = 0x00000000;
					break;
				}

				//Determine Movement 2
				switch((dance_moves[i] >> 20) & 0xf) {
				case 0: //Right
					TextData[32] = 0x0000110b;
					TextData[40] = 0x00000000;
					break;
				case 1: //Left
					TextData[32] = 0x00000b0a;
					TextData[40] = 0x00000000;
					break;
				case 2: //Up
					TextData[32] = 0x0000000d;
					TextData[40] = 0x0000000f;
					break;
				case 3: //Down
					TextData[32] = 0x0000000f;
					TextData[40] = 0x0000000e;
					break;
				case 5: //Arc Down Right
					TextData[32] = 0x00000012;
					TextData[40] = 0x00000013;
					break;
				case 7: //Arc Down Left
					TextData[32] = 0x00000015;
					TextData[40] = 0x00000016;
					break;
				case 8: //Arc Top Right
					TextData[32] = 0x00001917;
					TextData[40] = 0x00000000;
					break;
				case 9: //Arc Top Right
					TextData[32] = 0x00001b1a;
					TextData[40] = 0x00000000;
					break;
				}

				XOsd_CreateInstruction(&xosd_inst, InstSetPtr+8, 1, XOSD_INS_OPCODE_TXT, 0x80, x1, y1, x1+0x80, y1, 0x2, colour1); //Arrow 1 (UPPER)
				XOsd_CreateInstruction(&xosd_inst, InstSetPtr+12, 1, XOSD_INS_OPCODE_TXT, 0x80, x1, y1+0x40, x1+0x80, y1+0x40, 0x3, colour1); //Arrow 1 (LOWER)
				XOsd_CreateInstruction(&xosd_inst, InstSetPtr+16, 1, XOSD_INS_OPCODE_TXT, 0x80, x2, y2, x2+0x80, y2, 0x4, colour2); //Arrow 2 (UPPER)
				XOsd_CreateInstruction(&xosd_inst, InstSetPtr+20, 1, XOSD_INS_OPCODE_TXT, 0x80, x2, y2+0x40, x2+0x80, y2+0x40, 0x5, colour2); //Arrow 2 (LOWER)

				//Update Text Bank and Instructions
				XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
				XOsd_LoadInstructionList(&xosd_inst, 1, 1, InstSetPtr, 6);

				//Delay between showing instruction on the screen and actually tracking movement
				MB_Sleep(500);

				MOTIONDEIP_mWriteReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG0_OFFSET, dance_moves[i]);
				while((COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x1) == 0) {
					MB_Sleep(100);
				}

				int result = (COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x7);
				xil_printf("Move: %d. Score: %d\r\n", i, result);

				//Check Score
				if ((result == 7) && (colour1 != colour2)) {
					score += 2;
				} else if (result > 1) {
					score += 1;
				}

				//Update Score Value on Screen
				switch (score)
				{
				case  0:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x66663c00; TextData[19] = 0x003c6666; break;
				case  1:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x0c0c1800; TextData[19] = 0x001e0c0c; break;
				case  2:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x7c067c00; TextData[19] = 0x007e6060; break;
				case  3:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x3c067c00; TextData[19] = 0x007c0606; break;
				case  4:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x66666600; TextData[19] = 0x0006063e; break;
				case  5:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x7c607e00; TextData[19] = 0x007c0606; break;
				case  6:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x7c603e00; TextData[19] = 0x007c6666; break;
				case  7:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x06667c00; TextData[19] = 0x00060606; break;
				case  8:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x3c663c00; TextData[19] = 0x003c6666; break;
				case  9:	TextData[14] = 0x66663c00; TextData[15] = 0x003c6666; TextData[18] = 0x3e663c00; TextData[19] = 0x007c0606; break;
				case  10:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x66663c00; TextData[19] = 0x003c6666; break;
				case  11:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x0c0c1800; TextData[19] = 0x001e0c0c; break;
				case  12:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x7c067c00; TextData[19] = 0x007e6060; break;
				case  13:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x3c067c00; TextData[19] = 0x007c0606; break;
				case  14:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x66666600; TextData[19] = 0x0006063e; break;
				case  15:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x7c607e00; TextData[19] = 0x007c0606; break;
				case  16:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x7c603e00; TextData[19] = 0x007c6666; break;
				case  17:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x06667c00; TextData[19] = 0x00060606; break;
				case  18:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x3c663c00; TextData[19] = 0x003c6666; break;
				case  19:	TextData[14] = 0x0c0c1800; TextData[15] = 0x001e0c0c; TextData[18] = 0x3e663c00; TextData[19] = 0x007c0606; break;
				case  20:	TextData[14] = 0x7c067c00; TextData[15] = 0x007e6060; TextData[18] = 0x66663c00; TextData[19] = 0x003c6666; break;
				}

			}

			//Print GAME OVER
			TextData[20] = 0x60603c00; //G
			TextData[21] = 0x003c6666;
			TextData[22] = 0x663c1800; //A
			TextData[23] = 0x00667e66;
			TextData[26] = 0x54282800; //M
			TextData[27] = 0x00444444;
			TextData[28] = 0x66666600; //V
			TextData[29] = 0x00183c66;

			TextData[16] = 0x060d0b0a;
			TextData[17] = 0x00000000;
			TextData[24] = 0x05060e03;
			TextData[25] = 0x00000000;

			XOsd_CreateInstruction(&xosd_inst, InstSetPtr+8, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x200, 0x100, 0x4ff, 0x100, 0x2, 0xc);
			XOsd_CreateInstruction(&xosd_inst, InstSetPtr+12, 1, XOSD_INS_OPCODE_TXT, 0x80, 0x200, 0x140, 0x4ff, 0x140, 0x3, 0xc);

			XOsd_LoadTextBank(&xosd_inst, 1, 1, TextData);
			XOsd_LoadInstructionList(&xosd_inst, 1, 1, InstSetPtr, 4);

			MB_Sleep(5000);

			//After Game Over, Check for new HIGH SCORE, return to main menu
			if (score > high_score) {
				high_score = score;
			}

			XOsd_DisableLayer(&xosd_inst, 0);

			goto TITLE_SCREEN;

			break;

		case 'q':
			//TODO Display THANKS FOR PLAYING!
			break;

		case 'r':
			locked = XGpio_DiscreteRead(GpioPtr, 2);
			xil_printf("%d", locked);
			break;

		//DEBUG/TESTING ONLY, NOT PART OF GAME
		case 't':

			XOsd_EnableLayer(&xosd_inst, 0);

			//Test
			COLORDETECT2_mWriteReg(XPAR_COLORDETECT2_0_S00_AXI_BASEADDR, COLORDETECT2_S00_AXI_SLV_REG0_OFFSET, 0x00000010);

			xil_printf("Writing to MotionDetector\r\n");
			MOTIONDEIP_mWriteReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG0_OFFSET, 0x00100019);
			xil_printf("Reading from MotionDetector\r\n");
			while((COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x1) == 0) {
				MB_Sleep(200);
				xil_printf("Reading Red Coordinates: %x\r\n", COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG2_OFFSET));
				xil_printf("Reading Yellow Coordinates: %x\r\n", COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG3_OFFSET));
			}

			xil_printf("%d\r\n", (COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x7));

			MB_Sleep(1000);


			xil_printf("Writing to MotionDetector\r\n");
			MOTIONDEIP_mWriteReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG0_OFFSET, 0x00010013);
			xil_printf("Reading from MotionDetector\r\n");
			while((COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x1) == 0) {
				MB_Sleep(200);
				xil_printf("Reading Green Coordinates: %x\r\n", COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG2_OFFSET));
				xil_printf("Reading Blue Coordinates: %x\r\n", COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG3_OFFSET));
			}

			xil_printf("%d\r\n", (COLORDETECT2_mReadReg(XPAR_MOTIONDEIP_0_S00_AXI_BASEADDR, MOTIONDEIP_S00_AXI_SLV_REG1_OFFSET) & 0x7));

			XOsd_DisableLayer(&xosd_inst, 0);

			break;

		case '+':
			high_score++;
			goto TITLE_SCREEN;
			break;

		default :
			//xil_printf("\n\rInvalid Selection");
			MB_Sleep(50);
		}
	}

	return 0;
}

/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */
void DemoInitialize()
{
	int Status;
	XAxiVdma_Config *vdmaConfig;
	int i;

	/*
	 * Initialize an array of pointers to the 3 frame buffers
	 */
	for (i = 0; i < DISPLAY_NUM_FRAMES; i++)
	{
		pFrames[i] = frameBuf[i];
	}

	/*
	 * Initialize VDMA driver
	 */
	vdmaConfig = XAxiVdma_LookupConfig(VGA_VDMA_ID);
	if (!vdmaConfig)
	{
		xil_printf("No video DMA found for ID %d\r\n", VGA_VDMA_ID);
		return;
	}
	Status = XAxiVdma_CfgInitialize(&vdma, vdmaConfig, vdmaConfig->BaseAddress);
	if (Status != XST_SUCCESS)
	{
		xil_printf("VDMA Configuration Initialization failed %d\r\n", Status);
		return;
	}

	/*
	 * Initialize the Display controller and start it
	 */
	Status = DisplayInitialize(&dispCtrl, &vdma, DISP_VTC_ID, DYNCLK_BASEADDR, pFrames, DEMO_STRIDE);
	if (Status != XST_SUCCESS)
	{
		xil_printf("Display Ctrl initialization failed during demo initialization%d\r\n", Status);
		return;
	}
	Status = DisplayStart(&dispCtrl);
	if (Status != XST_SUCCESS)
	{
		xil_printf("Couldn't start display during demo initialization%d\r\n", Status);
		return;
	}

	/*
	 * Initialize the Interrupt controller and start it.
	 */
	Status = fnInitInterruptController(&intc);
	if(Status != XST_SUCCESS) {
		xil_printf("Error initializing interrupts");
		return;
	}
	fnEnableInterrupts(&intc, &ivt[0], sizeof(ivt)/sizeof(ivt[0]));

	/*
	 * Initialize the Video Capture device
	 */
	Status = VideoInitialize(&videoCapt, &intc, &vdma, VID_GPIO_ID, VID_VTC_ID, VID_VTC_IRPT_ID, pFrames, DEMO_STRIDE, DEMO_START_ON_DET);
	if (Status != XST_SUCCESS)
	{
		xil_printf("Video Ctrl initialization failed during demo initialization%d\r\n", Status);
		return;
	}

	/*
	 * Set the Video Detect callback to trigger the menu to reset, displaying the new detected resolution
	 */
	VideoSetCallback(&videoCapt, DemoISR, &fRefresh);

	//DemoPrintTest(dispCtrl.framePtr[dispCtrl.curFrame], dispCtrl.vMode.width, dispCtrl.vMode.height, dispCtrl.stride, DEMO_PATTERN_1);

	return;
}

void DemoISR(void *callBackRef, void *pVideo)
{
	char *data = (char *) callBackRef;
	*data = 1; //set fRefresh to 1
}
