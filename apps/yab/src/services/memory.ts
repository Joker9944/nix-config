import GTop from "gi://GTop"
import { createPoll } from "ags/time"

const mem = new GTop.glibtop_mem()

function utilization(): number {
	GTop.glibtop_get_mem(mem)
	return ((mem.total - mem.free - mem.cached - mem.buffer) / mem.total) * 100
}

export const utilizationAccessor = createPoll(-1, 1000, () => utilization())
