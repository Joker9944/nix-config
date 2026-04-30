import { formatPercentage, lazyAccessor } from "../../../helpers"
import { batteryIconAccessor, percentageAccessor } from "../../../services/battery"
import { IconStatModule } from "./Module"

export default function Battery(): JSX.Element {
	return <IconStatModule name="battery" icon={batteryIconAccessor} value={batteryPercentage} />
}

const batteryPercentage = lazyAccessor(() => {
	return percentageAccessor.as((percentage) => formatPercentage(percentage * 100))
})
