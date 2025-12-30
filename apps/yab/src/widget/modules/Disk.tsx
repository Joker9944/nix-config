import { StatModule } from "./Module"
import accessorFromPath from "../../services/disk"
import { Accessor } from "ags"
import { formatPercentage } from "../../helpers/formatters"

export default function Disk({ label = "Disk", path = "/" }) {
	return <StatModule name="disk" label={label} value={diskUsage(path)} />
}

function diskUsage(path: string): Accessor<string> {
	return accessorFromPath(path).as((usage) => formatPercentage(usage))
}
