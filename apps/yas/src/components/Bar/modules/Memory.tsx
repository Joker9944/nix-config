import { formatPercentage, lazyAccessor } from "../../../helpers"
import { utilizationAccessor } from "../../../services/memory"
import { LabelStatModule } from "./Module"

export default function Memory({ label = "Mem" }): JSX.Element {
	return <LabelStatModule name="memory" label={label} value={memoryUtilization} />
}

const memoryUtilization = lazyAccessor(() => {
	return utilizationAccessor.as((utilization) => formatPercentage(utilization))
})
