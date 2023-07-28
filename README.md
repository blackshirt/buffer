# buffer
Simple bytes reader in pure V, adapted from go version of bytes.Reader

## Contents

## new_reader_with_endianess
```v
fn new_reader_with_endianess(b []u8, endian bool) &Reader
```

new_reader_with_endianess create new reader.  



## new_reader
```v
fn new_reader(b []u8) &Reader
```

create new Reader with big endianess set to true, for more other option, see `new_reader_with_endianess` function.  



## Reader
## reset
```v
fn (mut r Reader) reset(b []u8)
```

resets the Reader to be reading from b



## remainder
```v
fn (r &Reader) remainder() int
```

remainder tells the length of unread portion of buffer.  



## cap
```v
fn (r &Reader) cap() i64
```

cap return capacity or original size of the buffer.  



## sub_reader
```v
fn (mut r Reader) sub_reader(start i64, amount i64) !&Reader
```

sub_reader create sub Reader from defined current reader.  



## read_u8
```v
fn (mut r Reader) read_u8() !u8
```

read_u8 read one byte and updates current index



## read_byte
```v
fn (mut r Reader) read_byte() !u8
```

read_byte is an alias for read_u8



## peek_u8
```v
fn (mut r Reader) peek_u8() !u8
```

peek_u8 peek one byte without udpates current index



## read
```v
fn (mut r Reader) read(mut b []u8) !int
```

implements io.Reader read b.len bytes from reader, and updates current index



## peek
```v
fn (mut r Reader) peek(mut b []u8) !int
```

read b.len bytes from reader, without updates current index



## read_sized
```v
fn (mut r Reader) read_sized(size int) !([]u8, int)
```

read with size



## peek_sized
```v
fn (mut r Reader) peek_sized(size int) !([]u8, int)
```




## read_at_least
```v
fn (mut r Reader) read_at_least(amount int) ![]u8
```

read in amount size from current offset



## skip
```v
fn (mut r Reader) skip(amount int)
```

skip amount of bytes and updates index, its similar to peek but only update the index.  



## read_to_end
```v
fn (mut r Reader) read_to_end() ![]u8
```

read from current index to the end of the buffer update the idx to the last



## read_u16
```v
fn (mut r Reader) read_u16() !u16
```

read u16 size (two byte) from reader



## peek_u16
```v
fn (mut r Reader) peek_u16() !u16
```

peek u16 size (two bytes) from reader.  



## read_u32
```v
fn (mut r Reader) read_u32() !u32
```




## peek_u32
```v
fn (mut r Reader) peek_u32() !u32
```




## read_u64
```v
fn (mut r Reader) read_u64() !u64
```




## peek_u64
```v
fn (mut r Reader) peek_u64() !u64
```




## remaining
```v
fn (r &Reader) remaining() ![]u8
```

remaining bytes without update the index



#### Powered by vdoc. Generated on: 28 Jul 2023 17:38:01
