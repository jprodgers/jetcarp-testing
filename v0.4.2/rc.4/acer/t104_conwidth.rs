// R4 #104 diagnosis on the Acer: a small console program (windows-sys 0.61.2, as JETCARP) that reports what
// GetConsoleScreenBufferInfo and GetConsoleMode give on stderr, and with --esc writes `\r ESC[2K` and a 95-column line
// three times. Built offline in a scratch crate (Cargo.toml: windows-sys = "=0.61.2", features Win32_Foundation and
// Win32_System_Console). Run in a 60-column conhost from cmd with stdout redirected, it saw width 60 and output mode
// 0x7, and its escape code was interpreted.
// What JETCARP's term::asked_columns sees: GetConsoleScreenBufferInfo on standard error (and on stdout).
use std::io::IsTerminal;
use windows_sys::Win32::System::Console::{
    GetConsoleMode, GetConsoleScreenBufferInfo, GetStdHandle, CONSOLE_SCREEN_BUFFER_INFO, STD_ERROR_HANDLE,
    STD_OUTPUT_HANDLE,
};
fn main() {
    for (name, which) in [("stderr", STD_ERROR_HANDLE), ("stdout", STD_OUTPUT_HANDLE)] {
        unsafe {
            let h = GetStdHandle(which);
            let mut info: CONSOLE_SCREEN_BUFFER_INFO = std::mem::zeroed();
            let ok = GetConsoleScreenBufferInfo(h, &mut info);
            let err = std::io::Error::last_os_error();
            let mut mode = 0u32;
            let mok = GetConsoleMode(h, &mut mode);
            println!(
                "{name}: handle {:?}; GetConsoleScreenBufferInfo -> {ok} ({err}); size {}x{}; window L{} R{} T{} B{} => width {}; GetConsoleMode -> {mok}, mode {mode:#x}",
                h, info.dwSize.X, info.dwSize.Y, info.srWindow.Left, info.srWindow.Right, info.srWindow.Top,
                info.srWindow.Bottom, i32::from(info.srWindow.Right) - i32::from(info.srWindow.Left) + 1
            );
        }
    }
    println!("stderr is_terminal: {}; COLUMNS: {:?}", std::io::stderr().is_terminal(), std::env::var("COLUMNS").ok());
    if std::env::args().any(|a| a == "--esc") {
        use std::io::Write;
        let line = "probe: a line of ninety-five characters, wider than the sixty columns of this console, ends here.";
        for i in 0..3 {
            eprint!("\r\x1b[2K{line} {i}");
            let _ = std::io::stderr().flush();
            std::thread::sleep(std::time::Duration::from_millis(300));
        }
        eprintln!();
    }
}
