import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

function utilization(): Promise<string> {
	return execAsync([
		"nvidia-smi",
		"--query-gpu=utilization.gpu",
		"--format=csv,noheader,nounits", // cSpell:words noheader nounits
	]).then((out) => out.trim())
}

export const accessor = createPoll("-1", 1000, () => utilization())
