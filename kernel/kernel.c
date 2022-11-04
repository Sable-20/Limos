#include <limine.h>
#include <stddef.h>
#include <stdint.h>

// make requests volatile so compiler doesnt
// optimize it away
static volatile struct limine_terminal_request terminal_request = {
  .id = LIMINE_TERMINAL_REQUEST, 
  .revision = 0
};


// hang convenience function
static void done(void) {
  for (;;) {
    __asm__("hlt");
  }
}

// kernel entry point
void _start(void) {
  // ensure terminal connection
  if (terminal_request.response == NULL
  ||  terminal_request.reponse->terminal_count < 1) {
    // TODO: error later, for now hang
    done();
  }

  // simple hello world, do more later
  struct limine_terminal *terminal = terminal_request.response->terminals[0];
  terminal_request.response->write(terminal, "Hello world", 11);

  // hang for now
}