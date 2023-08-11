import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

var rnd = getSecureRandom();
var domainParams = ECDomainParameters("secp256k1");

String encrypt(var rawPubKeyCompUncomp, var plaintext) {
  // 1. Create ephemeral key pair
  var ephKeyPair = (KeyGenerator("EC")
        ..init(
            ParametersWithRandom(ECKeyGeneratorParameters(domainParams), rnd)))
      .generateKeyPair();

  // 2. Import public key of receiver
  var ecPoint = domainParams.curve.decodePoint(hex.decode(rawPubKeyCompUncomp));
  var publicKey = ECPublicKey(ecPoint, domainParams);

  // 3. Get full point to ECDH shared secret, derive AES key via HKDF
  var sharedSecretECPointUncomp =
      (publicKey.Q! * (ephKeyPair.privateKey as ECPrivateKey).d)!
          .getEncoded(false);
  var ephPublicKeyUncomp =
      (ephKeyPair.publicKey as ECPublicKey).Q!.getEncoded(false);
  var aesKey = hkdf(ephPublicKeyUncomp, sharedSecretECPointUncomp);

  // 4. Encrypt via AES-256, GCM
  var nonce = rnd.nextBytes(16);
  List<int> myIntList = plaintext.codeUnits;

  var ciphertextTag = (GCMBlockCipher(AESEngine())
        ..init(true,
            AEADParameters(KeyParameter(aesKey), 128, nonce, Uint8List(0))))
      .process(Uint8List.fromList(myIntList));

  // 5. Concatenate (ephemeral public key|nonce|tag|ciphertext), Base64 encode and return
  return base64.encode(ephPublicKeyUncomp +
      nonce +
      ciphertextTag.sublist(ciphertextTag.length - 16) +
      ciphertextTag.sublist(0, ciphertextTag.length - 16));
}

SecureRandom getSecureRandom() {
  List<int> seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return FortunaRandom()..seed(KeyParameter(Uint8List.fromList(seed)));
}

Uint8List hkdf(var ephPublicKeyUnc, var sharedSecretEcPointUnc) {
  var master = Uint8List.fromList(ephPublicKeyUnc + sharedSecretEcPointUnc);
  var aesKey = Uint8List(32);
  (HKDFKeyDerivator(SHA256Digest())..init(HkdfParameters(master, 32, null)))
      .deriveKey(null, 0, aesKey, 0);
  return aesKey;
}

String decrypt(var rawPrivKeyHex, var encryptedDataB64) {
  // 1. Import private key
  var privateKey =
      ECPrivateKey(BigInt.parse(rawPrivKeyHex, radix: 16), domainParams);

  // 2. Separate ephemeral public key and nonce|tag|ciphertext, import ephemeral public key
  var encryptedData = base64.decode(encryptedDataB64);
  var ephPublicKey = ECPublicKey(
      domainParams.curve.decodePoint(encryptedData.sublist(0, 65)),
      domainParams);
  var nonceTagCiphertext = encryptedData.sublist(65);

  // 3. Get full point to ECDH shared secret, derive AES key via HKDF
  var sharedSecretECPointUncomp =
      (ephPublicKey.Q! * privateKey.d)!.getEncoded(false);
  var ephPublicKeyUncomp = ephPublicKey.Q!.getEncoded(false);
  var aesKey = hkdf(ephPublicKeyUncomp, sharedSecretECPointUncomp);

  // 4. Decrypt via AES-256, GCM
  var nonce = nonceTagCiphertext.sublist(0, 16);
  var ciphertextTag = nonceTagCiphertext.sublist(16 + 16) +
      nonceTagCiphertext.sublist(16, 16 + 16);
  var plaintext = (GCMBlockCipher(AESEngine())
        ..init(false,
            AEADParameters(KeyParameter(aesKey), 128, nonce, Uint8List(0))))
      .process(Uint8List.fromList(ciphertextTag));

  // 5. UTF-8 decode and return
  return utf8.decode(plaintext);
}
