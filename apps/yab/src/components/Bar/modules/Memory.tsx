import { StatModule } from "./Module"
import { utilizationAccessor } from "../../../services/memory"
import { formatPercentage } from "../../../helpers"

export default function Memory({ label = "Mem" }): JSX.Element {
	return <StatModule name="memory" label={label} value={memoryUtilization} />
}

const memoryUtilization = utilizationAccessor.as((utilization) =>
	formatPercentage(utilization)
)
