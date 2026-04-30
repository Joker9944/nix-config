import { Gdk } from "ags/gtk4"

import AstalNotifd from "gi://AstalNotifd"
import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import { SPACING, formatUnixTime } from "../../helpers"
import { fileExists } from "../../helpers/files"

export default function Notification({
	notification,
	showHeader = false,
	showActions = false,
}: {
	notification: AstalNotifd.Notification
	showHeader?: boolean
	showActions?: boolean
}): JSX.Element {
	return (
		<box
			cssName="notification"
			cssClasses={["frame", "background", urgency(notification)]}
			widthRequest={400}
			orientation={Gtk.Orientation.VERTICAL}
			$={(self) => {
				const gesture = new Gtk.GestureClick()
				gesture.connect("pressed", () => {
					notification.dismiss()
				})
				self.add_controller(gesture)
			}}
		>
			{showHeader && (
				<box cssName="header">
					{(notification.appIcon || isIcon(notification.desktopEntry)) && (
						<image
							class="app-icon"
							visible={Boolean(notification.appIcon || notification.desktopEntry)}
							iconName={notification.appIcon || notification.desktopEntry}
						/>
					)}
					<label
						class="app-name"
						halign={Gtk.Align.START}
						ellipsize={Pango.EllipsizeMode.END}
						label={notification.appName || "Unknown"}
					/>
					<label class="time" hexpand halign={Gtk.Align.END} label={formatUnixTime(notification.time, "%H:%M")} />
				</box>
			)}
			{showHeader && <Gtk.Separator orientation={Gtk.Orientation.HORIZONTAL} cssClasses={["spacer"]} />}
			<box cssName="content" spacing={SPACING.NORMAL}>
				{notification.image && fileExists(notification.image) && (
					<image valign={Gtk.Align.START} class="image" file={notification.image} pixelSize={128} />
				)}
				{notification.image && isIcon(notification.image) && (
					<box valign={Gtk.Align.START} class="icon-image">
						<image iconName={notification.image} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER} />
					</box>
				)}
				{notification.image && <Gtk.Separator orientation={Gtk.Orientation.VERTICAL} cssClasses={["spacer"]} />}
				<box orientation={Gtk.Orientation.VERTICAL} valign={Gtk.Align.CENTER}>
					<label
						cssClasses={["summary", "heading"]}
						halign={Gtk.Align.START}
						xalign={0}
						label={notification.summary}
						ellipsize={Pango.EllipsizeMode.END}
					/>
					{notification.body && (
						<label
							class="body"
							wrap
							useMarkup
							halign={Gtk.Align.START}
							xalign={0}
							justify={Gtk.Justification.FILL}
							label={notification.body}
						/>
					)}
				</box>
			</box>
			{showActions && notification.actions.length > 0 && (
				<Gtk.Separator orientation={Gtk.Orientation.HORIZONTAL} cssClasses={["spacer"]} />
			)}
			{showActions && notification.actions.length > 0 && (
				<box cssName="actions" spacing={SPACING.NORMAL}>
					{notification.actions.map(({ label, id }) => (
						<button hexpand onClicked={() => notification.invoke(id)}>
							<label label={label} halign={Gtk.Align.CENTER} hexpand />
						</button>
					))}
				</box>
			)}
		</box>
	)
}

function isIcon(icon?: string | null) {
	const iconTheme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default()!)
	return icon && iconTheme.has_icon(icon)
}

function urgency(notification: AstalNotifd.Notification) {
	const { LOW, NORMAL, CRITICAL } = AstalNotifd.Urgency
	switch (notification.urgency) {
		case LOW:
			return "low"
		case CRITICAL:
			return "critical"
		case NORMAL:
		default:
			return "normal"
	}
}
