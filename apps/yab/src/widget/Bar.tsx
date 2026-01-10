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
import {showGpu} from "../services/config";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	return (
		<window
			visible
			name="bar"
			class="Bar"
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
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
					{(showGpu) && (
						<Gpu />
					)}
					<Memory />
					<Disk />
					<Network />
					<Volume />
				</box>
			</centerbox>
		</window>
	)
}
