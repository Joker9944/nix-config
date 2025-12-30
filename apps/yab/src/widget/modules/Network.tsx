import { speedAccessor } from "../../services/network"
import { Module } from "./Module"
import Gtk from "gi://Gtk"

export default function Network({ label = "Net" }) {
	return (
		<Module name={"network"}>
			<label cssClasses={["font-bold"]} label={label} />
			<box orientation={Gtk.Orientation.VERTICAL}>
				<label
					cssName="value"
					cssClasses={["font-mono", "font-xs"]}
					label={upSpeed}
				/>
				<label
					cssName="value"
					cssClasses={["font-mono", "font-xs"]}
					label={downSPeed}
				/>
			</box>
		</Module>
	)
}

const upSpeed = speedAccessor.as((speed) => formatSpeed(speed.up))
const downSPeed = speedAccessor.as((speed) => formatSpeed(speed.down))

const DECIMAL_PLACES = 1
const MAX_PADDING_LENGTH = 12

const BIT_TO_KIBIBITS = 1024
const BIT_TO_MEBIBITS = 1048576
const BIT_TO_GIBIBITS = 1073741824

function formatSpeed(speed: number): string {
	if (speed < BIT_TO_KIBIBITS) {
		return `${speed.toFixed(DECIMAL_PLACES)}   b/s`.padStart(
			MAX_PADDING_LENGTH,
			" "
		)
	} else if (speed < BIT_TO_MEBIBITS) {
		return `${(speed / BIT_TO_KIBIBITS).toFixed(
			DECIMAL_PLACES
		)} Kib/s`.padStart(MAX_PADDING_LENGTH, " ")
	} else if (speed < BIT_TO_GIBIBITS) {
		return `${(speed / BIT_TO_MEBIBITS).toFixed(
			DECIMAL_PLACES
		)} Mib/s`.padStart(MAX_PADDING_LENGTH, " ")
	} else {
		return `${(speed / BIT_TO_GIBIBITS).toFixed(
			DECIMAL_PLACES
		)} Gib/s`.padStart(MAX_PADDING_LENGTH, " ")
	}
}
