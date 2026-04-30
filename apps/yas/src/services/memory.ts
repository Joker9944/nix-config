import { createPoll } from "ags/time"

import GTop from "gi://GTop"

import { lazyAccessor } from "../helpers"

const mem = new GTop.glibtop_mem()

function utilization(): number {
	GTop.glibtop_get_mem(mem)
	return ((mem.total - mem.free - mem.cached - mem.buffer) / mem.total) * 100
}

export const utilizationAccessor = lazyAccessor(() => {
	return createPoll(-1, 1000, () => utilization())
})
