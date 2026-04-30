import Gtk from "gi://Gtk?version=4.0"

import { formatSpeed, lazyAccessor } from "../../../helpers"
import { speedAccessor } from "../../../services/network"
import { Module } from "./Module"

export default function Network({ label = "Net" }): JSX.Element {
	return (
		<Module name={"network"}>
			<label cssClasses={["heading"]} label={label} />
			<box orientation={Gtk.Orientation.VERTICAL} valign={Gtk.Align.CENTER}>
				<label cssName="value" cssClasses={["monospace"]} label={upSpeed} />
				<label cssName="value" cssClasses={["monospace"]} label={downSpeed} />
			</box>
		</Module>
	)
}

const upSpeed = lazyAccessor(() => {
	return speedAccessor.as((speed) => formatSpeed(speed.up))
})

const downSpeed = lazyAccessor(() => {
	return speedAccessor.as((speed) => formatSpeed(speed.down))
})
