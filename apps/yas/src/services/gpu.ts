import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

import { lazyAccessor } from "../helpers"

function utilization(): Promise<string> {
	return execAsync([
		"nvidia-smi",
		"--query-gpu=utilization.gpu",
		"--format=csv,noheader,nounits", // cSpell:words noheader nounits
	]).then((out) => out.trim())
}

export const utilizationAccessor = lazyAccessor(() => {
	return createPoll("-", 1000, () => utilization())
})
