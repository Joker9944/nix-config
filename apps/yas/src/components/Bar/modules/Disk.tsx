import { formatPercentage, memoize } from "../../../helpers"
import { utilizationAccessor } from "../../../services/disk"
import { LabelStatModule } from "./Module"

export default function Disk({ label = "Disk", path = "/" }): JSX.Element {
	return <LabelStatModule name="disk" label={label} value={formattedUtilizationAccessors(path)} />
}

const formattedUtilizationAccessors = memoize((path: string) => {
	return utilizationAccessor(path).as((usage) => formatPercentage(usage))
})
