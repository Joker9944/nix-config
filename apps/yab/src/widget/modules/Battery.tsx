import {Module} from "./Module";
import {batteryIconAccessor, percentageAccessor} from "../../services/battery";
import {formatPercentage} from "../../helpers/formatters";


export default function Battery() {
	return (
		<Module name="battery">
			<image iconName={batteryIconAccessor} />
			<label cssName="value" cssClasses={["font-mono"]} label={batteryPercentage} />
		</Module>
	)
}

const batteryPercentage = percentageAccessor.as((percentage) =>
	formatPercentage(percentage * 100)
)
