import GTop from "gi://GTop"
import { createPoll } from "ags/time"

const cpu = new GTop.glibtop_cpu()
GTop.glibtop_get_cpu(cpu)

let previousTotal = cpu.total
let previousIdle = cpu.idle

function utilization(): number {
	GTop.glibtop_get_cpu(cpu)

	const currentTotal = cpu.total
	const currentIdle = cpu.idle

	const deltaTotal = currentTotal - previousTotal
	const deltaIdle = currentIdle - previousIdle

	previousTotal = currentTotal
	previousIdle = currentIdle

	return (1 - deltaIdle / deltaTotal) * 100
}

export const utilizationAccessor = createPoll<number>(-1, 1000, () =>
	utilization()
)
