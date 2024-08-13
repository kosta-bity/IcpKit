//
//  Bls12381_Bridging_Header.h
//
//  Created by Konstantinos Gaitanis on 05.05.23.
//

#ifndef Bls12381_Bridging_Header_h
#define Bls12381_Bridging_Header_h
#ifdef __cplusplus
extern "C" {
#endif

int bls_instantiate();
int bls_verify(long autographSize, const char *autograph,
               long messageSize, const char *message,
               long keySize, const char *key);

#ifdef __cplusplus
}
#endif
#endif /* Bls12381_Bridging_Header_h */
