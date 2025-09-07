use std::{
    io::Read,
    path::{Path, PathBuf},
};

use flate2::read::ZlibDecoder;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    const DEFAULT_CORPUS_DIR: &str = "corpus";
    let mut args = std::env::args();

    // Skip first argument
    args.next();

    let corpus_dir = if let Some(dir) = args.next() {
        println!("Dir is {dir}");
        dir
    } else {
        DEFAULT_CORPUS_DIR.to_string()
    };

    if !std::fs::exists(&corpus_dir)? {
        std::fs::create_dir(&corpus_dir)?;
    }

    const HEADER_SIZE: usize = 4;
    const SLA_VERSION: u8 = 4;

    for (name, sla_data) in sleigh_config::SLA_DATA {
        assert!(sla_data.len() > HEADER_SIZE);
        assert_eq!(sla_data[0], b's');
        assert_eq!(sla_data[1], b'l');
        assert_eq!(sla_data[2], b'a');
        assert_eq!(sla_data[3], SLA_VERSION);

        // Decompress input
        let mut decoder = ZlibDecoder::new(&sla_data[4..]);
        let mut decoded = Vec::new();
        decoder
            .read_to_end(&mut decoded)
            .expect("failed to decode zlib compressed sla spec data");
        assert!(!decoded.is_empty(), "decoded data should not be empty");

        let mut raw_filename = PathBuf::from(name.replace("::", "_"));
        raw_filename.set_extension("rsla");
        std::fs::write(Path::new(&corpus_dir).join(&raw_filename), &decoded)?;
        println!("Wrote {raw_filename:?}");
    }

    Ok(())
}
