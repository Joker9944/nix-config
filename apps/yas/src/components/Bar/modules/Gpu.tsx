import { lazyAccessor } from "../../../helpers"
import { utilizationAccessor } from "../../../services/gpu"
import { LabelStatModule } from "./Module"

export default function Gpu({ label = "GPU" }): JSX.Element {
	return <LabelStatModule name="gpu" label={label} value={gpuUtilization} />
}

const gpuUtilization = lazyAccessor(() => {
	return utilizationAccessor.as((utilization) => formatUtilization(utilization))
})

function formatUtilization(utilization: string): string {
	return `${utilization}%`.padStart(4, " ")
}
