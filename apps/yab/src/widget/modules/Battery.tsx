import {StatModule} from "./Module";
import {percentageAccessor} from "../../services/battery";
import {formatPercentage} from "../../helpers/formatters";


export default function Battery({ label = "Bat" }) {
	return <StatModule name="battery" label={label} value={batteryPercentage} />
}

const batteryPercentage = percentageAccessor.as((percentage) =>
	formatPercentage(percentage * 100)
)
