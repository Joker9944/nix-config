import { Module } from "./Module"
import { nowAccessor } from "../../../services/clock"
import { formatDateTime, memoize } from "../../../helpers"

export default function Clock({ format = "%d. %b %H:%M" }): JSX.Element {
	return (
		<Module name="clock">
			<label cssClasses={["font-bold"]} label={formattedNowAccessors(format)} />
		</Module>
	)
}

const formattedNowAccessors = memoize((format: string) => {
	return nowAccessor.as((dateTime) => formatDateTime(dateTime, format))
})
