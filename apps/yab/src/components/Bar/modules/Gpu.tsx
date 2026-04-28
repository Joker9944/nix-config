import { StatModule } from "./Module"
import { utilizationAccessor } from "../../../services/gpu"
import { lazyAccessor } from "../../../helpers"

export default function Gpu({ label = "GPU" }): JSX.Element {
	return <StatModule name="gpu" label={label} value={gpuUtilization} />
}

const gpuUtilization = lazyAccessor(() => {
	return utilizationAccessor.as((utilization) => formatUtilization(utilization))
})

function formatUtilization(utilization: string): string {
	return `${utilization}%`.padStart(4, " ")
}
