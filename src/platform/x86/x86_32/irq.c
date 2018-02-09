#include <kernel.h>
#include <print.h>

#include "irq.h"
#include "idt.h"

void irq_initialize() {
#define _ "\n\t.word 0x00eb, 0x00eb\n\t" // Wait
    asm(
        // Start Initialize
        "mov $0x11, %al\n\t"
        "out %al, $0x20" _
        "out %al, $0xA0" _

        // Remap Interupts
        "mov $0x20, %al\n\t"
        "out %al, $0x21" _
        "mov $0x28, %al\n\t"
        "out %al, $0xA1" _
        
        // Set Master and Slave
        "mov $0x4, %al\n\t"
        "out %al, $0x21" _
        "mov $0x2, %al\n\t"
        "out %al, $0xA1" _

        "mov $0x01, %al\n\t"
        "out %al, $0x21" _
        "out %al, $0xA1" _

        "mov $0x00, %al\n\t"
        "out %al, $0x21" _
        "out %al, $0xA1" _
    );

    // Trigger IRQ0, lowest frequency
    out1(PIT_MODE, 0x34);
    out1(PIT_CHANNEL, 0xFF);
    out1(PIT_CHANNEL, 0xFF);

    // Register IRQ0
    idt_set_handler(32, &ih_irq0);
}

void irq0_handle() {
    pit_reset(0);
    print_char('I');
    context_switch(&currentp->context, schedulerc);
}