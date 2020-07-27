// The wasm-pack uses wasm-bindgen to build and generate  binding file.
// Import the wasm-bindgen crate.
use wasm_bindgen::prelude::*;
use ethereum_types::{H256};
use parity_bytes::BytesRef;

pub fn main () {}


/** the following is copied from ethcore/src/builtin.rs **/

// Copyright 2015-2019 Parity Technologies (UK) Ltd.
// This file is part of Parity Ethereum.

// Parity Ethereum is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Parity Ethereum is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Parity Ethereum.  If not, see <http://www.gnu.org/licenses/>.

/// Execution error.
#[derive(Debug)]
pub struct Error(pub &'static str);

// impl From<&'static str> for Error {
//   fn from(val: &'static str) -> Self {
//     Error(val)
//   }
// }
//
// impl Into<vm::Error> for Error {
//   fn into(self) -> ::vm::Error {
//     vm::Error::BuiltIn(self.0)
//   }
// }

#[derive(Debug)]
struct EcRecover;

impl EcRecover {
  fn execute(&self, i: &[u8], output: &mut BytesRef) -> Result<(), Error> {
    let len = min(i.len(), 128);

    let mut input = [0; 128];
    input[..len].copy_from_slice(&i[..len]);

    let hash = secp256k1::Message::parse(&H256::from_slice(&input[0..32]).0);
    let v = &input[32..64];
    let r = &input[64..96];
    let s = &input[96..128];

    let bit = match v[31] {
      27..=30 => v[31] - 27,
      _ => { return Ok(()); },
    };

    let mut sig = [0u8; 64];
    sig[..32].copy_from_slice(&r);
    sig[32..].copy_from_slice(&s);
    let s = secp256k1::Signature::parse(&sig);

    if let Ok(rec_id) = secp256k1::RecoveryId::parse(bit) {
      if let Ok(p) = secp256k1::recover(&hash, &s, &rec_id) {
        // recover returns the 65-byte key, but addresses come from the raw 64-byte key
        // let r = keccak256(&mut p.serialize()[1..]);
        let r = &mut p.serialize()[1..];
        keccak256(r);
        output.write(0, &[0; 12]);
        // TODO why
        output.write(12, &r[12..]);
      }
    }

    Ok(())
  }
}