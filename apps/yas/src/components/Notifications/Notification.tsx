import { Gdk } from "ags/gtk4"

import Adw from "gi://Adw?version=1"
import AstalNotifd from "gi://AstalNotifd"
import Gio from "gi://Gio?version=2.0"
import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import { SPACING, formatUnixTime, resolveBody } from "../../helpers"
import { fileExists } from "../../helpers/files"

const NOTIFICATION_SIZE = 600

type Visual = { kind: "picture"; path: string } | { kind: "icon"; name: string } | null

export default function Notification({
	notification,
	showHeader = false,
	showActions = false,
}: {
	notification: AstalNotifd.Notification
	showHeader?: boolean
	showActions?: boolean
}): JSX.Element {
	const visual = resolveVisual(notification)
	const body = resolveBody(notification.body)

	return (
		<Adw.Clamp maximumSize={NOTIFICATION_SIZE}>
			<box
				cssName="notification"
				cssClasses={["frame", "background", urgency(notification)]}
				widthRequest={NOTIFICATION_SIZE}
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
					{visual?.kind === "picture" && (
						<Adw.Clamp maximumSize={128}>
							<Gtk.Picture
								class="app-picture"
								valign={Gtk.Align.CENTER}
								contentFit={Gtk.ContentFit.SCALE_DOWN}
								file={Gio.File.new_for_path(visual.path)}
							/>
						</Adw.Clamp>
					)}
					{visual?.kind === "icon" && (
						<box valign={Gtk.Align.CENTER} halign={Gtk.Align.START} class="app-icon">
							<image
								iconName={visual.name}
								iconSize={Gtk.IconSize.LARGE}
								halign={Gtk.Align.CENTER}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					{visual !== null && <Gtk.Separator orientation={Gtk.Orientation.VERTICAL} cssClasses={["spacer"]} />}
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
								useMarkup={body.markup}
								halign={Gtk.Align.START}
								xalign={0}
								justify={Gtk.Justification.FILL}
								label={body.text}
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
		</Adw.Clamp>
	)
}

function resolveVisual(notification: AstalNotifd.Notification): Visual {
	if (notification.image) {
		if (fileExists(notification.image)) return { kind: "picture", path: notification.image }
		if (isIcon(notification.image)) return { kind: "icon", name: notification.image }
		return null
	}

	if (notification.appIcon) {
		if (isIcon(notification.appIcon)) return { kind: "icon", name: notification.appIcon }
		if (fileExists(notification.appIcon)) return { kind: "picture", path: notification.appIcon }
	}

	if (notification.desktopEntry && isIcon(notification.desktopEntry)) {
		return { kind: "icon", name: notification.desktopEntry }
	}

	return null
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
