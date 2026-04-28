import { StatModule } from "./Module"
import { utilizationAccessor } from "../../../services/cpu"
import { formatPercentage, lazyAccessor } from "../../../helpers"

export default function Cpu({ label = "CPU" }): JSX.Element {
	return <StatModule name="cpu" label={label} value={cpuUtilization} />
}

const cpuUtilization = lazyAccessor(() => {
	return utilizationAccessor.as((utilization) => formatPercentage(utilization))
})
