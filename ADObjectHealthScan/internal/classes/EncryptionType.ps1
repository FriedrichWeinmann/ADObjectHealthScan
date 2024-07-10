[flags()]enum EncryptionType {
	DesCbcCrc = 1
	DesCbcMD5 = 2
	RRC4 = 4
	AES128 = 8
	AES256 = 16
	AES256SK = 32

	FastSupported = 65536
	CompoundIdentitySupported = 131072
	ClaimsSupported = 262144
	ResourceSIDCompressionDisabled = 524288
}