module buffer

import encoding.binary
import blackshirt.u24

// Simple and general purposes bytes reader inspired by Golang bytes.Reader
// Its mainly backed by two methods for reading a byte or bytes array.
//    - type of method that updates curent offset (index) of underlying buffers, and
//    - type of method that does not udpates current index, for looking data.
// for 3 bytes long (24 bit) handling, its depends on `u24` module. Its available on my github.

struct Reader {
	// read only buffer of underlying data being wrapped
	buf []u8
	// default to big endian read
	endian bool = true
mut:
	// current index (offset)
	idx i64
}

// create new Reader with big endianess set to true, for more other option, see `new_reader_with_endianess` function.
pub fn new_reader(b []u8) &Reader {
	return new_reader_with_endianess(b, true)
}

// new_reader_with_endianess create new reader.
pub fn new_reader_with_endianess(b []u8, endian bool) &Reader {
	return &Reader{
		buf: b
		idx: i64(0)
		endian: endian
	}
}

pub fn (mut r Reader) free() {
	unsafe { r.buf.free() }
	r.idx = i64(0)
}
	
// resets the Reader to be reading from b
pub fn (mut r Reader) reset(b []u8) {
	r = Reader{
		buf: b
		idx: i64(0)
		endian: true
	}
}

// current_index tells current index of the reader
pub fn (r Reader) current_index() i64 {
	return r.idx 
}

// remainder tells the length of unread portion of buffer.
pub fn (r &Reader) remainder() int {
	if r.idx >= r.cap() {
		return 0
	}
	return int(r.cap() - r.idx)
}

// cap return capacity or original size of the buffer.
pub fn (r &Reader) cap() i64 {
	return i64(r.buf.len)
}

// sub_reader create sub Reader from defined current reader.
pub fn (mut r Reader) sub_reader(start i64, amount i64) !&Reader {
	if start < r.idx {
		return error('start below current index')
	}
	if amount > r.remainder() {
		return error('amount exceed unread length')
	}
	if start + amount > r.cap() {
		return error('start+amount exceed cap')
	}

	b := r.buf[start..start + amount]
	reader := new_reader_with_endianess(b, r.endian)
	// original reader need update index, because the bytes has been consumed
	// TODO; give a flag for convenience
	r.idx += 1

	return reader
}

// seek_byte look a single byte at current index
fn (mut r Reader) seek_byte(upd_idx bool) !u8 {
	// make sure there are remaining bytes to look
	if r.remainder() <= 0 {
		return error('nothing to look, remainder <= 0')
	}
	// check the current index is valid
	if r.idx >= r.cap() {
		return error('io.Eof')
	}
	// make sure we're not access outside maximum capacity of the buffer
	if r.idx < r.cap() {
		b := r.buf[r.idx]
		if upd_idx {
			r.idx += i64(1)
		}
		return b
	}
	return error('access byte at ${r.idx} maybe out of boundary')
}

// read_u8 read one byte and updates current index
pub fn (mut r Reader) read_u8() !u8 {
	return r.seek_byte(true)
}

// read_byte is an alias for read_u8
pub fn (mut r Reader) read_byte() !u8 {
	return r.read_u8()!
}

// peek_u8 peek one byte without udpates current index
pub fn (mut r Reader) peek_u8() !u8 {
	return r.seek_byte(false)
}

fn (mut r Reader) seek_bytes(mut b []u8, upd_idx bool) !int {
	if r.idx > r.cap() {
		return error('io.Eof')
	}
	if r.remainder() <= 0 {
		return error('no data')
	}
	// make sure there are enought bytes to read on
	// and copied to destination buffer b.
	if b.len > r.remainder() {
		return error('not enought bytes to read on to copy to dest b')
	}
	n := copy(mut b, r.buf[r.idx..])

	if upd_idx {
		r.idx += i64(n)
	}
	return n
}

// implements io.Reader
// read b.len bytes from reader, and updates current index
pub fn (mut r Reader) read(mut b []u8) !int {
	return r.seek_bytes(mut b, true)
}

// read b.len bytes from reader, without updates current index
pub fn (mut r Reader) peek(mut b []u8) !int {
	return r.seek_bytes(mut b, false)
}

// read with size
pub fn (mut r Reader) read_sized(size int) !([]u8, int) {
	mut buf := []u8{len: size}
	n := r.read(mut buf)!
	if n != size {
		return error('mismatch size an n, maybe overflow cap')
	}
	return buf, n
}

// peek_sized peek with size
pub fn (mut r Reader) peek_sized(size int) !([]u8, int) {
	mut buf := []u8{len: size}
	n := r.peek(mut buf)!
	if n != size {
		return error('mismatch size an n, maybe overflow cap')
	}
	return buf, n
}

// read in amount size from current offset
pub fn (mut r Reader) read_at_least(amount int) ![]u8 {
	if amount <= 0 {
		return empty
	}
	remain := r.remainder()
	if amount > remain {
		return error('amount to read is bigger than remaining bytes')
	}
	if r.idx + i64(amount) > r.cap() {
		return error('overflow cap')
	}

	res := r.buf[r.idx..r.idx + i64(amount)]

	// update current offset
	r.idx += i64(amount)

	return res
}

// skip amount of bytes and updates index, its similar to peek but only update the index.
pub fn (mut r Reader) skip(amount int) {
	r.idx += i64(amount)
	assert r.idx < r.cap()
}

// read from current index to the end of the buffer
// update the idx to the last
pub fn (mut r Reader) read_to_end() ![]u8 {
	if r.remainder() <= 0 {
		return empty
	}
	length := r.cap() - r.idx
	rest := r.buf[r.idx..r.idx + length]

	r.idx += length
	return rest
}

// read u16 size (two byte) from reader
pub fn (mut r Reader) read_u16() !u16 {
	if r.remainder() < u16size {
		return error('read_u16: not enough bytes to read on')
	}
	b := r.read_at_least(u16size)!

	if r.endian {
		return binary.big_endian_u16(b)
	}
	return binary.little_endian_u16(b)
}

// peek u16 size (two bytes) from reader.
pub fn (mut r Reader) peek_u16() !u16 {
	if r.remainder() < u16size {
		return error('peek_u16: not enough bytes to read on')
	}
	b, _ := r.peek_sized(u16size)!

	// assert n == u16size
	if r.endian {
		return binary.big_endian_u16(b)
	}
	return binary.little_endian_u16(b)
}

// read_u24 read 3 bytes from reader, and return integer and updates index
pub fn (mut r Reader) read_u24() !int {
	if r.remainder() < u24size {
		return error('read_u24: not enough bytes to read on')
	}
	bytes, n := r.read_sized(u24size)!
	assert n == u24size
	u24val := if r.endian {
		u24.from_big_endian_bytes(bytes)!
	} else {
		u24.from_little_endian_bytes(bytes)!
	}
	val := u24val.to_int()!

	return val
}

// peek_u24 peek 3 bytes from reader without updates index.
pub fn (mut r Reader) peek_u24() !int {
	if r.remainder() < u24size {
		return error('peek_u24: not enough bytes to read on')
	}
	bytes, n := r.peek_sized(u24size)!
	assert n == u24size

	if r.endian {
		u24val := u24.from_big_endian_bytes(bytes)!
		val := u24val.to_int()!
		return val
	}
	u24val := u24.from_little_endian_bytes(bytes)!
	val := u24val.to_int()!
	return val
}

// read_u32 read u32size bytes data from reader and updatea index
pub fn (mut r Reader) read_u32() !u32 {
	b, n := r.read_sized(u32size)!
	assert n == u32size
	if r.endian {
		return binary.big_endian_u32(b)
	}
	return binary.little_endian_u32(b)
}

// peek_u32 peek u32size bytes fron reader without updates index
pub fn (mut r Reader) peek_u32() !u32 {
	b, n := r.peek_sized(u32size)!
	assert n == u32size
	if r.endian {
		return binary.big_endian_u32(b)
	}
	return binary.little_endian_u32(b)
}

// read_u64 read u64size (8) bytes from reader and updates index
pub fn (mut r Reader) read_u64() !u64 {
	b, n := r.read_sized(u64size)!
	assert n == u64size
	if r.endian {
		return binary.big_endian_u64(b)
	}
	return binary.little_endian_u64(b)
}

// peek_u64 peek u64size bytes from reader withhout updates index.
pub fn (mut r Reader) peek_u64() !u64 {
	b, n := r.peek_sized(u64size)!
	assert n == u64size
	if r.endian {
		return binary.big_endian_u64(b)
	}
	return binary.little_endian_u64(b)
}

// remaining bytes without update the index
pub fn (r &Reader) remaining() ![]u8 {
	if r.remainder() >= 0 {
		return r.buf[r.idx..]
	}
	return error('remaining bytes was empty')
}
