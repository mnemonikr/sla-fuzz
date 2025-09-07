#![cfg_attr(not(test), no_main)]

use libfuzzer_sys::fuzz_target;
use libsla::{GhidraSleigh, SlaDecoder};

fuzz_target!(|data: &[u8]| {
    let _ = GhidraSleigh::builder()
        .processor_spec("<processor_spec></processor_spec>")
        .expect("processor spec should be valid")
        .sla_decoder(SlaDecoder::Raw)
        .build(data);
});
