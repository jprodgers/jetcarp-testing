//! Finding filed as jprodgers/jetcarp#173: the state hash leaves out a turmite's internal state.
//! Fails at a3e829a; should pass once the issue is fixed.
use jetcarp_core::*;

#[test]
fn state_hash_covers_turmite_internal_state() {
    for rule in ["Turmite 1R1,1R1/1N0,0N0", "Turmite 1L1,1L1/1R1,0N0"] {
        let mk = || {
            let mut w = World::new(TilingSpec::rect("square", 32, 32, Boundary::Wrap), 5).unwrap();
            w.add_ca(CaSpec::new(rule).seed(SeedSpec::Ants { count: 1 })).unwrap();
            w
        };
        let (mut a, mut b) = (mk(), mk());
        for _ in 0..37 {
            a.step();
            b.step();
        }
        assert_eq!(a.hash_hex(), b.hash_hex());
        // The only difference between the two worlds: one turmite's internal state.
        b.cas[0].agents[0].state = 1 - b.cas[0].agents[0].state;
        let same_hash = a.hash_hex() == b.hash_hex();
        a.step();
        b.step();
        let differ_next = a.fields[0].state != b.fields[0].state || a.cas[0].agents != b.cas[0].agents;
        println!("{rule}: same hash straight after the change = {same_hash}; worlds differ one generation later = {differ_next}");
        assert!(!same_hash, "{rule}: two worlds with different futures share a state hash");
    }
}
