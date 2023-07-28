module buffer

fn test_reader_operation_tls13_xargs_org() ! {
	// data from https://tls13.xargs.org/#server-hello
	serverhello_data := [u8(0x03), 0x03, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
		0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
		0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x20, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5,
		0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4,
		0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x13, 0x02, 0x00, 0x00,
		0x2e, 0x00, 0x2b, 0x00, 0x02, 0x03, 0x04, 0x00, 0x33, 0x00, 0x24, 0x00, 0x1d, 0x00, 0x20,
		0x9f, 0xd7, 0xad, 0x6d, 0xcf, 0xf4, 0x29, 0x8d, 0xd3, 0xf9, 0x6d, 0x5b, 0x1b, 0x2a, 0xf9,
		0x10, 0xa0, 0x53, 0x5b, 0x14, 0x88, 0xd7, 0xf8, 0xfa, 0xbb, 0x34, 0x9a, 0x98, 0x28, 0x80,
		0xB6, 0x15]

	mut r := new_reader(serverhello_data)
	ver := r.read_u16()!
	assert ver == 0x0303
	assert r.idx == 2

	random := r.read_at_least(32)!
	exp_random := [u8(0x70), 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b,
		0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a,
		0x8b, 0x8c, 0x8d, 0x8e, 0x8f]
	assert random == exp_random
	assert r.idx == 34

	// read one byte sessid length
	b := r.read_byte()!
	assert b == 0x20 // 32 length
	assert r.idx == 35
	// read the sessid
	sessid, n := r.read_sized(32)!
	exp_sessid := [u8(0xe0), 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb,
		0xec, 0xed, 0xee, 0xef, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa,
		0xfb, 0xfc, 0xfd, 0xfe, 0xff]
	assert n == 32
	assert sessid == exp_sessid
	assert r.idx == 67

	// read two byte of ciphersuite
	cs := r.read_u16()!
	assert cs == 0x1302
	assert r.idx == 69

	// read one byet compression method
	cm := r.read_u8()!
	assert cm == u8(0x00)
	assert r.idx == 70

	// read extension length, 2 bytes
	el := r.read_u16()!
	assert el == 0x002e
	assert r.idx == 72

	assert r.remainder() == 46

	rest := r.remaining()!
	rest_data := [u8(0x00), 0x2b, 0x00, 0x02, 0x03, 0x04, 0x00, 0x33, 0x00, 0x24, 0x00, 0x1d, 0x00,
		0x20, 0x9f, 0xd7, 0xad, 0x6d, 0xcf, 0xf4, 0x29, 0x8d, 0xd3, 0xf9, 0x6d, 0x5b, 0x1b, 0x2a,
		0xf9, 0x10, 0xa0, 0x53, 0x5b, 0x14, 0x88, 0xd7, 0xf8, 0xfa, 0xbb, 0x34, 0x9a, 0x98, 0x28,
		0x80, 0xB6, 0x15]
	assert rest == rest_data
	assert r.cap() == 72 + 46
}

fn test_reader_operation_tls13_zig() ! {
	data := [u8(0x03), 0x03, 0x11, 0x08, 0x43, 0x1b, 0xd0, 0x42, 0x9e, 0x61, 0xff, 0x65, 0x44,
		0x41, 0x91, 0xfc, 0x56, 0x10, 0xf8, 0x27, 0x53, 0xd9, 0x68, 0xc8, 0x13, 0x00, 0xb1, 0xec,
		0x11, 0xd5, 0x7d, 0x90, 0xa5, 0x43, 0x20, 0xc4, 0x8a, 0x5c, 0x30, 0xa8, 0x50, 0x1b, 0x2e,
		0xc2, 0x45, 0x76, 0xd7, 0xf0, 0x11, 0x52, 0xa0, 0x16, 0x57, 0x07, 0xdf, 0x01, 0x30, 0x47,
		0x5b, 0x94, 0xbc, 0xe7, 0x86, 0x1e, 0x41, 0x97, 0x65, 0x13, 0x02, 0x00, 0x00, 0x4f, 0x00,
		0x2b, 0x00, 0x02, 0x03, 0x04, 0x00, 0x33, 0x00, 0x45, 0x00, 0x17, 0x00, 0x41, 0x04, 0x27,
		0x66, 0x69, 0x3d, 0xd8, 0xd1, 0x76, 0xa8, 0x8f, 0x6a, 0xe6, 0x61, 0x06, 0x89, 0xe1, 0xe9,
		0xcd, 0x63, 0xef, 0x2e, 0x79, 0x41, 0x24, 0x86, 0x26, 0x37, 0xfa, 0x83, 0xd9, 0xfd, 0xa3,
		0xc5, 0xaa, 0xbc, 0xaa, 0xb5, 0x85, 0x86, 0x98, 0x21, 0x54, 0xbc, 0x81, 0xed, 0x30, 0x35,
		0x42, 0xb2, 0x89, 0xd6, 0xa4, 0xc4, 0x94, 0x75, 0x41, 0x49, 0x90, 0x78, 0x03, 0xaa, 0xf5,
		0x6d, 0xfc, 0x47]

	mut r := new_reader(data)
	ver := r.read_u16()!
	assert ver == 0x0303
	assert r.idx == 2

	random, n := r.read_sized(32)!
	exp_random := [u8(0x11), 0x08, 0x43, 0x1b, 0xd0, 0x42, 0x9e, 0x61, 0xff, 0x65, 0x44, 0x41,
		0x91, 0xfc, 0x56, 0x10, 0xf8, 0x27, 0x53, 0xd9, 0x68, 0xc8, 0x13, 0x00, 0xb1, 0xec, 0x11,
		0xd5, 0x7d, 0x90, 0xa5, 0x43]
	assert n == 32
	assert random == exp_random
	assert r.idx == 34

	// read one byte session id length
	b := r.read_u8()!
	assert b == 0x20
	assert r.idx == 35

	// read session id based on length
	sessid, sn := r.read_sized(int(b))!
	assert b == sn
	exp_sessid := [u8(0xc4), 0x8a, 0x5c, 0x30, 0xa8, 0x50, 0x1b, 0x2e, 0xc2, 0x45, 0x76, 0xd7,
		0xf0, 0x11, 0x52, 0xa0, 0x16, 0x57, 0x07, 0xdf, 0x01, 0x30, 0x47, 0x5b, 0x94, 0xbc, 0xe7,
		0x86, 0x1e, 0x41, 0x97, 0x65]
	assert sessid == exp_sessid
	assert r.idx == 67

	// read 2 byte ciphersuite
	cs := r.read_u16()!
	assert cs == 0x1302
	assert r.idx == 69
	// one byte compression method 0x00
	cm := r.read_u8()!
	assert cm == 0x00
	assert r.idx == 70

	// extension list
	// read 2 byte extensionlist length
	eln := r.read_u16()!
	assert eln == 0x004f // 79

	assert r.remaining()!.len == 79

	rest := r.read_to_end()!
	assert rest.len == 79
	assert r.idx == 151 // cap

	ext_data := [u8(0x00), 0x2b, 0x00, 0x02, 0x03, 0x04, 0x00, 0x33, 0x00, 0x45, 0x00, 0x17, 0x00,
		0x41, 0x04, 0x27, 0x66, 0x69, 0x3d, 0xd8, 0xd1, 0x76, 0xa8, 0x8f, 0x6a, 0xe6, 0x61, 0x06,
		0x89, 0xe1, 0xe9, 0xcd, 0x63, 0xef, 0x2e, 0x79, 0x41, 0x24, 0x86, 0x26, 0x37, 0xfa, 0x83,
		0xd9, 0xfd, 0xa3, 0xc5, 0xaa, 0xbc, 0xaa, 0xb5, 0x85, 0x86, 0x98, 0x21, 0x54, 0xbc, 0x81,
		0xed, 0x30, 0x35, 0x42, 0xb2, 0x89, 0xd6, 0xa4, 0xc4, 0x94, 0x75, 0x41, 0x49, 0x90, 0x78,
		0x03, 0xaa, 0xf5, 0x6d, 0xfc, 0x47]
	assert rest == ext_data
}
