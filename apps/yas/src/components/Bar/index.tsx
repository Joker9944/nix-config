import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"

import { SPACING } from "../../helpers"
import { showBattery, showGpu } from "../../services/config"
import Audio from "./modules/Audio"
import Battery from "./modules/Battery"
import Clock from "./modules/Clock"
import Cpu from "./modules/Cpu"
import Disk from "./modules/Disk"
import Gpu from "./modules/Gpu"
import Memory from "./modules/Memory"
import Network from "./modules/Network"
import Workspaces from "./modules/Workspaces"

type BarProps = {
	gdkmonitor: Gdk.Monitor
}

export default function Bar({ gdkmonitor }: BarProps): JSX.Element {
	const { EXCLUSIVE } = Astal.Exclusivity
	const { BOTTOM } = Astal.Layer
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	return (
		<window
			layer={BOTTOM} // WORKAROUND Due to a hyprland bug the layer has to be defined at the top: https://github.com/Aylur/astal/issues/332
			visible
			name={`yab_${gdkmonitor.get_connector()}`}
			gdkmonitor={gdkmonitor}
			exclusivity={EXCLUSIVE}
			anchor={TOP | LEFT | RIGHT}
			application={app}
		>
			<centerbox cssName="bar" cssClasses={["background"]}>
				<box $type="start">
					<Workspaces connector={gdkmonitor.get_connector()!} />
				</box>

				<box $type="center">
					<Clock />
				</box>

				<box $type="end" spacing={SPACING.RELAXED}>
					<Cpu />
					{showGpu && <Gpu />}
					<Memory />
					<Disk />
					<Network />
					{showBattery && <Battery />}
					<Audio />
				</box>
			</centerbox>
		</window>
	)
}
