#include <limine.h>
#include <stddef.h>
#include <stdint.h>

// make requests volatile so compiler doesnt
// optimize it away
static volatile struct limine_terminal_request terminal_request = {
    .id = LIMINE_TERMINAL_REQUEST, .revision = 0};

static void done(void) {
  for (;;) {
    __asm__("hlt");
  }
}