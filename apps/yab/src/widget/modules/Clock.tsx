import { Accessor } from "ags"
import { Module } from "./Module"
import { nowAccessor } from "../../services/clock"
import { formatDateTime } from "../../helpers/formatters"

export default function Clock({ format = "%d. %b %H:%M" }) {
	return (
		<Module name="clock">
			<label cssClasses={["font-bold"]} label={now(format)} />
		</Module>
	)
}

function now(format: string): Accessor<string> {
	return nowAccessor.as((dateTime) => formatDateTime(dateTime, format))
}
