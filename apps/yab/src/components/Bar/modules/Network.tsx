import { speedAccessor } from "../../../services/network";
import { Module } from "./Module";
import Gtk from "gi://Gtk";
import { formatSpeed } from "../../../helpers";

export default function Network({ label = "Net" }): JSX.Element {
	return (
		<Module name={"network"}>
			<label cssClasses={["font-bold"]} label={label} />
			<box orientation={Gtk.Orientation.VERTICAL} valign={Gtk.Align.CENTER}>
				<label
					cssName="value"
					cssClasses={["font-mono", "font-xs"]}
					label={upSpeed}
				/>
				<label
					cssName="value"
					cssClasses={["font-mono", "font-xs"]}
					label={downSpeed}
				/>
			</box>
		</Module>
	);
}

const upSpeed = speedAccessor.as((speed) => formatSpeed(speed.up));
const downSpeed = speedAccessor.as((speed) => formatSpeed(speed.down));
