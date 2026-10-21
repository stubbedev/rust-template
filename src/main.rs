use std::io::{self, Write as _};

fn main() -> io::Result<()> {
    return writeln!(io::stdout().lock(), "{}", greet("world"));
}

fn greet(name: &str) -> String {
    return format!("hello, {name}");
}

#[cfg(test)]
mod tests {
    use super::greet;

    #[test]
    fn greets_by_name() {
        for (name, want) in [("world", "hello, world"), ("ferris", "hello, ferris")] {
            assert_eq!(greet(name), want, "greet({name:?})");
        }
    }
}
