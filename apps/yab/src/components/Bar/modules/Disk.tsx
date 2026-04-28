import { StatModule } from "./Module"
import { formatPercentage, memoize } from "../../../helpers"
import { utilizationAccessor } from "../../../services/disk"

export default function Disk({ label = "Disk", path = "/" }): JSX.Element {
	return <StatModule name="disk" label={label} value={formattedUtilizationAccessors(path)} />
}

const formattedUtilizationAccessors = memoize((path: string) => {
	return utilizationAccessor(path).as((usage) => formatPercentage(usage))
})
