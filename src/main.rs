#![no_std]
#![no_main]

mod io;

use limine::LimineBootInfoRequest;

static BOOTLOADER_INFO: LimineBootInfoRequest = LimineBootInfoRequest::new(0);

// entry point
#[no_mangle]
pub extern "C" fn _start() -> ! {
  println!("Hello world!");

  if let Some(bootinfo) = BOOTLOADER_INFO.get_response().get() {
    println!(
      "booted by {} v{}",
      bootinfo.name.to_str().unwrap().to_str().unwrap(),
      bootinfo.version.to_str().unwrap().to_str().unwrap(),
    );
  }

  hcf();
}

#[panic_handler]
fn rust_panic(info: &core::panic::PanicInfo) -> ! {
  println!("{}", info);
  hcf();
}

// die in a glorious blaze (... loop lol)
fn hcf() -> ! {
  loop {
    core::hint::spin_loop();
  }
}