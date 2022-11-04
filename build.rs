use std::{
  env, 
  error::Error};

fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
  // get pkg name
  let kern_name = env::var("CARGO_PKG_NAME")?;

  // pass linker script to linker
  println!("cargo:rustc-link-arg-bin={kern_name}=--script=conf/linker.ld");

  // rerun if linker or CARGO_PKG_ENV changes
  println!("cargo:rerun-if-changed=conf/linker.ld");
  println!("cargo:rerun-if-env-changed=CARGO_PKG_NAME");

  Ok(())
}