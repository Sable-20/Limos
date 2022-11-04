use core::fmt;
use limine::LimineTerminalRequest;
use spin::Mutex;

static TERM_REQ: LimineTerminalRequest = LimineTerminalRequest::new(0);

struct Writer {
  terminals: Option<&'static limine::LimineTerminalResponse>,
}

unsafe impl Send for Writer {}

impl fmt::Write for Writer {
  fn write_str(&mut self, s: &str) -> fmt::Result {
    // get res and cache
    let res = match self.terminals {
      None => {
        let res = TERM_REQ.get_response().get().ok_or(fmt::Error)?;
        self.terminals = Some(res);
        res
      }
      Some(resp) => resp,
    };

    let write = res.write().ok_or(fmt::Error)?;

    // output str to each term
    for terminal in res.terminals() {
      write(terminal, s);
    }

    Ok(())
  }
}

static WRITER: Mutex<Writer> = Mutex::new(Writer { terminals: None });

pub fn _print(args: fmt::Arguments) {
  // LOCK MUST HAPPEN AROUND `print_fmt` NOT `print_str`
  // otherwise it will possibly call the latter multiple times per call
  let mut writer = WRITER.lock();
  fmt::Write::write_fmt(&mut *writer, args).ok();
}

#[macro_export]
macro_rules! print {
  ($($t:tt)*) => { 
    $crate::io::_print(format_args!($($t)*))
  };
}

#[macro_export]
macro_rules! println {
  ()  => {
    $crate::print!("\n");
  };
  ($($t:tt)*) => {
    $crate::print!("{}\n", format_args!($($t)*));
  };
}