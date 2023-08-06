# buffer
Simple bytes reader in pure V, adapted from go version of bytes.Reader

## Installation
> ```$v install https://github.com/blackshirt/buffer```

## Contents
- [new_reader](#new_reader)
- [new_reader_with_endianess](#new_reader_with_endianess)
- [Reader](#Reader)
  - [reset](#reset)
  - [remainder](#remainder)
  - [cap](#cap)
  - [sub_reader](#sub_reader)
  - [read_u8](#read_u8)
  - [read_byte](#read_byte)
  - [peek_u8](#peek_u8)
  - [read](#read)
  - [peek](#peek)
  - [read_sized](#read_sized)
  - [peek_sized](#peek_sized)
  - [read_at_least](#read_at_least)
  - [skip](#skip)
  - [read_to_end](#read_to_end)
  - [read_u16](#read_u16)
  - [peek_u16](#peek_u16)
  - [read_u24](#read_u24)
  - [peek_u24](#peek_u24)
  - [read_u32](#read_u32)
  - [peek_u32](#peek_u32)
  - [read_u64](#read_u64)
  - [peek_u64](#peek_u64)
  - [remaining](#remaining)

## new_reader
```v
fn new_reader(b []u8) &Reader
```

create new Reader with big endianess set to true, for more other option, see `new_reader_with_endianess` function.  

[[Return to contents]](#Contents)

## new_reader_with_endianess
```v
fn new_reader_with_endianess(b []u8, endian bool) &Reader
```

new_reader_with_endianess create new reader.  

[[Return to contents]](#Contents)

## Reader
## reset
```v
fn (mut r Reader) reset(b []u8)
```

resets the Reader to be reading from b

[[Return to contents]](#Contents)

## remainder
```v
fn (r &Reader) remainder() int
```

remainder tells the length of unread portion of buffer.  

[[Return to contents]](#Contents)

## cap
```v
fn (r &Reader) cap() i64
```

cap return capacity or original size of the buffer.  

[[Return to contents]](#Contents)

## sub_reader
```v
fn (mut r Reader) sub_reader(start i64, amount i64) !&Reader
```

sub_reader create sub Reader from defined current reader.  

[[Return to contents]](#Contents)

## read_u8
```v
fn (mut r Reader) read_u8() !u8
```

read_u8 read one byte and updates current index

[[Return to contents]](#Contents)

## read_byte
```v
fn (mut r Reader) read_byte() !u8
```

read_byte is an alias for read_u8

[[Return to contents]](#Contents)

## peek_u8
```v
fn (mut r Reader) peek_u8() !u8
```

peek_u8 peek one byte without udpates current index

[[Return to contents]](#Contents)

## read
```v
fn (mut r Reader) read(mut b []u8) !int
```

implements io.Reader read b.len bytes from reader, and updates current index

[[Return to contents]](#Contents)

## peek
```v
fn (mut r Reader) peek(mut b []u8) !int
```

read b.len bytes from reader, without updates current index

[[Return to contents]](#Contents)

## read_sized
```v
fn (mut r Reader) read_sized(size int) !([]u8, int)
```

read with size

[[Return to contents]](#Contents)

## peek_sized
```v
fn (mut r Reader) peek_sized(size int) !([]u8, int)
```

peek_sized peek with size

[[Return to contents]](#Contents)

## read_at_least
```v
fn (mut r Reader) read_at_least(amount int) ![]u8
```

read in amount size from current offset

[[Return to contents]](#Contents)

## skip
```v
fn (mut r Reader) skip(amount int)
```

skip amount of bytes and updates index, its similar to peek but only update the index.  

[[Return to contents]](#Contents)

## read_to_end
```v
fn (mut r Reader) read_to_end() ![]u8
```

read from current index to the end of the buffer update the idx to the last

[[Return to contents]](#Contents)

## read_u16
```v
fn (mut r Reader) read_u16() !u16
```

read u16 size (two byte) from reader

[[Return to contents]](#Contents)

## peek_u16
```v
fn (mut r Reader) peek_u16() !u16
```

peek u16 size (two bytes) from reader.  

[[Return to contents]](#Contents)

## read_u24
```v
fn (mut r Reader) read_u24() !int
```

read_u24 read 3 bytes from reader, and return integer and updates index

[[Return to contents]](#Contents)

## peek_u24
```v
fn (mut r Reader) peek_u24() !int
```

peek_u24 peek 3 bytes from reader without updates index.  

[[Return to contents]](#Contents)

## read_u32
```v
fn (mut r Reader) read_u32() !u32
```

read_u32 read u32size bytes data from reader and updatea index

[[Return to contents]](#Contents)

## peek_u32
```v
fn (mut r Reader) peek_u32() !u32
```

peek_u32 peek u32size bytes fron reader without updates index

[[Return to contents]](#Contents)

## read_u64
```v
fn (mut r Reader) read_u64() !u64
```

read_u64 read u64size (8) bytes from reader and updates index

[[Return to contents]](#Contents)

## peek_u64
```v
fn (mut r Reader) peek_u64() !u64
```

peek_u64 peek u64size bytes from reader withhout updates index.  

[[Return to contents]](#Contents)

## remaining
```v
fn (r &Reader) remaining() ![]u8
```

remaining bytes without update the index

[[Return to contents]](#Contents)


