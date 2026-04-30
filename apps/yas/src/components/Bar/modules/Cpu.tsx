import { formatPercentage, lazyAccessor } from "../../../helpers"
import { utilizationAccessor } from "../../../services/cpu"
import { LabelStatModule } from "./Module"

export default function Cpu({ label = "CPU" }): JSX.Element {
	return <LabelStatModule name="cpu" label={label} value={cpuUtilization} />
}

const cpuUtilization = lazyAccessor(() => {
	return utilizationAccessor.as((utilization) => formatPercentage(utilization))
})
