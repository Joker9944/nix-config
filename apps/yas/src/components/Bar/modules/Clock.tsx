import { formatDateTime, memoize } from "../../../helpers"
import { nowAccessor } from "../../../services/clock"
import { Module } from "./Module"

export default function Clock({ format = "%d. %b %H:%M" }): JSX.Element {
	return (
		<Module name="clock">
			<label cssClasses={["heading"]} label={formattedNowAccessors(format)} />
		</Module>
	)
}

const formattedNowAccessors = memoize((format: string) => {
	return nowAccessor.as((dateTime) => formatDateTime(dateTime, format))
})
