#![cfg_attr(not(test), no_main)]

use libfuzzer_sys::fuzz_target;
use libsla::{GhidraSleigh, SlaDataEncoding};

fuzz_target!(|data: &[u8]| {
    let _ = GhidraSleigh::builder()
        .processor_spec("<processor_spec></processor_spec>")
        .expect("processor spec should be valid")
        .sla_encoding(SlaDataEncoding::Raw)
        .build(data);
});
