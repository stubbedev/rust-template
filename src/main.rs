use std::io::{self, Write as _};

fn main() -> io::Result<()> {
    return writeln!(io::stdout().lock(), "{}", rust_template::greet("world"));
}
