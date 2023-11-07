#[allow(clippy::all)]
#[allow(dead_code)]
mod bls;
use bls::bls12381::bls::{init, core_verify, BLS_OK}; //BLS_FAIL

#[no_mangle]
pub extern "C" fn bls_instantiate() -> i64 {
    if init() == BLS_OK {
        1
    } else {
        0
    }
}

#[no_mangle]
pub extern "C" fn bls_verify(
    autograph_size: i64, autograph_ptr: *const u8,
    message_size: i64, message_ptr: *const u8,
    key_size: i64, key_ptr: *const u8
) -> i64 {
    let autograph_array = unsafe { std::slice::from_raw_parts(autograph_ptr, autograph_size as usize) };
    let message_array = unsafe { std::slice::from_raw_parts(message_ptr, message_size as usize) };
    let key_array = unsafe { std::slice::from_raw_parts(key_ptr, key_size as usize) };
    if core_verify(&autograph_array, &message_array, &key_array) == BLS_OK {
        1
    } else {
        0
    }
}

