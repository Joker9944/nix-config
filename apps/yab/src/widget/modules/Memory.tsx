import { StatModule } from "./Module"
import { utilizationAccessor } from "../../services/memory"
import { formatPercentage } from "../../helpers/formatters"

export default function Memory({ label = "Mem" }) {
	return <StatModule name="memory" label={label} value={memoryUtilization} />
}

const memoryUtilization = utilizationAccessor.as((utilization) =>
	formatPercentage(utilization)
)
