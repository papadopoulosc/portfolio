/**************************************************************
Group 22 Maulik and Xaris
**************************************************************/

#include<stdio.h>
#include<x32.h>
#include<ucos.h>

#define PRIORITY 5
#define STACK_SIZE 1024

int stack[STACK_SIZE];
int stack_2[STACK_SIZE];
int stack_E[STACK_SIZE];

unsigned int reset_but;
static unsigned int throttle = 0;
static unsigned int increment, decrement, new_a, new_b, state_a, state_b;
static unsigned int count = 0;

OS_EVENT *error;


/*Implementation of 1a.3*/
void SSD(void *data)
{
int display_right,display_left,display, prev_count, speed;

	while(1)
	{
        /*throttle can take max value of 1023 - show proper display - same for speed*/
	speed = count - prev_count;
	speed = speed/10;
	display_right=throttle;
        display_left=(speed<<8);
	display=display_right|display_left;
    
	peripherals[PERIPHERAL_DISPLAY] = display;
	prev_count = count;
	printf("Value of Throttle is %d\n\r", throttle);
	OSTimeDly(1);
	}
}


void PWM(void *data)
{
	while(1)
	{
	peripherals[PERIPHERAL_DPC1_WIDTH] = throttle;
	OSTimeDly(1);
	}
}



void ERR(void *data)
{
	while(1)
	{
	OSSemPend(error,WAIT_FOREVER,0);

	peripherals[PERIPHERAL_LEDS] = 1;
	OSTimeDly(5);
	peripherals[PERIPHERAL_LEDS] = 0;
	while(OSSemAccept(error)>0);

	}
}


/*Interrupt Service Routine for the buttons*/
void isr_buttons()
{
	OSIntEnter();

	reset_but = peripherals[PERIPHERAL_BUTTONS]&0x00000008;
	decrement = peripherals[PERIPHERAL_BUTTONS]&0x00000002;
	increment = peripherals[PERIPHERAL_BUTTONS]&0x00000001;
	/*0x00000004 for (dis)engage*/
	if(reset_but==8)
		exit();
	else 
	if(increment==1&&throttle<255	)
		throttle++;
	else
	if(decrement==2 && throttle!=0)
		throttle--;
	

	OSIntExit();
}


void isr_decoder()
{
	OSIntEnter();

	new_a = peripherals[PERIPHERAL_ENGINE_A];
	new_b = peripherals[PERIPHERAL_ENGINE_B];

	if(new_a!=state_a && new_b!=state_b)
		OSSemPost(error);
	printf("Value of Throttle is %d\n\r", throttle);
	else if(new_a == 1 && new_b == 1)
		{
		if(state_b==0) count++;
		else count--;
		}
	state_a = new_a;
	state_b = new_b;	

	OSIntExit();
}






int main()

{
	OSInit();	//Initialisation

	OSTaskCreate(SSD, (void*)0, (void*)stack, PRIORITY);	//Display throttle value on SSD
	OSTaskCreate(PWM, (void*)100, (void*)stack_2, PRIORITY*2);	//Send the PWM value to Motor
	OSTaskCreate(ERR, (void*)200, (void*)stack_E, PRIORITY*3);	//Send the PWM value to Motor

	peripherals[PERIPHERAL_DPC1_PERIOD]=1024;			//Initialise the PWM period

	/*Set the interrupts*/
	SET_INTERRUPT_VECTOR(INTERRUPT_BUTTONS, isr_buttons);
	SET_INTERRUPT_PRIORITY(INTERRUPT_BUTTONS, 10);
	ENABLE_INTERRUPT(INTERRUPT_BUTTONS);

	/*interrupt for software decoder*/	
	SET_INTERRUPT_VECTOR(INTERRUPT_ENGINE_A, isr_decoder);
	SET_INTERRUPT_VECTOR(INTERRUPT_ENGINE_B, isr_decoder);
	SET_INTERRUPT_PRIORITY(INTERRUPT_ENGINE_A, 15);
	SET_INTERRUPT_PRIORITY(INTERRUPT_ENGINE_B, 15);
	ENABLE_INTERRUPT(INTERRUPT_ENGINE_A);
	ENABLE_INTERRUPT(INTERRUPT_ENGINE_B);
        
	error = OSSemCreate(0);

	OSStart();		//Start the OS

	return 0;

}
