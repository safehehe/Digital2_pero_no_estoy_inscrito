#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <libbase/uart.h>
#include <libbase/console.h>
#include <generated/csr.h>

int main(void)
{
#ifdef CONFIG_CPU_HAS_INTERRUPT
	irq_setmask(0);
	irq_setie(1);
#endif
	uart_init();//Importante para usar el printf
	while(1){
		int c;
		mult0_A_write(122);
		mult0_B_write(122);
		mult0_init_write(1);
		mult0_init_write(0);
		while(mult0_done_read() == 0){}
		c = mult0_pp_read();
		printf("Result=%d",c);
		busy_wait(1000);
	}
	return 0;
}
