import { StatModule } from "./Module"
import { accessor } from "../../services/gpu"

export default function Gpu({ label = "GPU" }) {
	return <StatModule name="gpu" label={label} value={gpuUtilization} />
}

const gpuUtilization = accessor.as((utilization) =>
	formatUtilization(utilization)
)

function formatUtilization(utilization: string): string {
	return `${utilization}%`.padStart(4, " ")
}
