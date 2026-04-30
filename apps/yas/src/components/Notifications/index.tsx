import { For, createComputed, onCleanup } from "ags"
import { Astal, Gdk } from "ags/gtk4"

import Gtk from "gi://Gtk?version=4.0"

import { SPACING, lazyAccessor } from "../../helpers"
import {
	dontDisturbAccessor,
	timeoutNotificationsAccessor,
} from "../../services/notifications"
import Notification from "./Notification"

export default function Notifications({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }): Astal.Window {
	return (
		<window
			layer={Astal.Layer.OVERLAY}
			visible={visibleAccessor}
			name={`yand_${gdkmonitor.get_connector()}`}
			class="Notifications"
			gdkmonitor={gdkmonitor}
			anchor={Astal.WindowAnchor.TOP}
			$={(self) => onCleanup(() => self.destroy())}
		>
			<box
				cssName="notifications"
				orientation={Gtk.Orientation.VERTICAL}
				margin_top={SPACING.NORMAL}
				spacing={SPACING.NORMAL}
			>
				<For each={timeoutNotificationsAccessor}>{(notification) => <Notification notification={notification} />}</For>
			</box>
		</window>
	) as Astal.Window
}

const visibleAccessor = lazyAccessor(() => {
	return createComputed(() => {
		return timeoutNotificationsAccessor().length > 0 && !dontDisturbAccessor()
	})
})
