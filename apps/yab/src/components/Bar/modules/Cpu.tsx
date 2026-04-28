import { StatModule } from "./Module"
import { utilizationAccessor } from "../../../services/cpu"
import { formatPercentage } from "../../../helpers"

export default function Cpu({ label = "CPU" }): JSX.Element {
	return <StatModule name="cpu" label={label} value={cpuUtilization} />
}

const cpuUtilization = utilizationAccessor.as((utilization) =>
	formatPercentage(utilization)
)
