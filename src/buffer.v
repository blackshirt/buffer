module buffer

import math

const (
	empty			= []u8{len:0, cap:0}
	u8size          = 1
	u16size         = 2
	u24size         = 3
	u32size         = 4
	u64size         = 8
	max_buffer_size = math.max_u16
)
