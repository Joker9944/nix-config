import { StatModule } from "./Module"
import { utilizationAccessor } from "../../services/cpu"
import { formatPercentage } from "../../helpers/formatters"

export default function Cpu({ label = "CPU" }) {
	return <StatModule name="cpu" label={label} value={cpuUtilization} />
}

const cpuUtilization = utilizationAccessor.as((utilization) =>
	formatPercentage(utilization)
)
