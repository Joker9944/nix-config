import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import Clock from "./modules/Clock"
import Cpu from "./modules/Cpu"
import Gpu from "./modules/Gpu"
import Memory from "./modules/Memory"
import Disk from "./modules/Disk"
import Network from "./modules/Network"
import Volume from "./modules/Volume"
import Workspaces from "./modules/Workspaces"
import { SPACING } from "../helpers/constants"
import { showBattery, showGpu } from "../services/config"
import Battery from "./modules/Battery"

export default function Bar(gdkmonitor: Gdk.Monitor): Astal.Window {
	const { EXCLUSIVE } = Astal.Exclusivity
	const { BOTTOM } = Astal.Layer
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	// @ts-ignore
	return (
		<window
			layer={BOTTOM} // WORKAROUND Due to a hyprland bug the layer has to be defined at the top: https://github.com/Aylur/astal/issues/332
			visible
			name="yab"
			class="Bar"
			gdkmonitor={gdkmonitor}
			exclusivity={EXCLUSIVE}
			anchor={TOP | LEFT | RIGHT}
			application={app}
		>
			<centerbox
				cssName="bar"
				cssClasses={[
					"active",
					"header-background",
					"m-0",
					"p-1",
					"font-base",
					"font-normal",
				]}
			>
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
					<Volume />
				</box>
			</centerbox>
		</window>
	)
}
