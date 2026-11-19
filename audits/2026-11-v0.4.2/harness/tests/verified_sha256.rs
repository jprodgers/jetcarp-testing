//! T7: jetcarp-core's own SHA-256 against the RustCrypto implementation, over every message
//! length around the block boundaries and some long messages.
use sha2::{Digest, Sha256};

#[test]
fn sha256_matches_rustcrypto() {
    let mut x: u64 = 0x1234_5678_9abc_def0;
    let mut next = || {
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        x as u8
    };
    let mut n = 0;
    for len in (0..=300usize).chain([511, 512, 513, 1000, 4095, 4096, 4097, 65535, 65536, 1_000_003]) {
        let data: Vec<u8> = (0..len).map(|_| next()).collect();
        let want: [u8; 32] = Sha256::digest(&data).into();
        assert_eq!(jetcarp_core::sha256::sha256(&data), want, "length {len}");
        // Incremental interface, split at an awkward point.
        let mut h = jetcarp_core::sha256::Sha256::new();
        let cut = len / 3;
        h.update(&data[..cut]);
        h.update(&data[cut..]);
        assert_eq!(h.finish(), want, "incremental, length {len}");
        n += 1;
    }
    assert_eq!(
        jetcarp_core::sha256::sha256_hex(b"abc"),
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    );
    println!("sha256: {n} message lengths agree with RustCrypto sha2");
}
