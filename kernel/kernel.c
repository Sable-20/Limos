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
  write(terminal, "Hello world", 11);

  // hang for now
  done();
}

void write(limine_terminal *term, char* text, uint_8 length) {
  terminal_request->response->write(term, text, length);
}