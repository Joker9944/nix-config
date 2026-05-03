import { Gdk } from "ags/gtk4"

import Adw from "gi://Adw?version=1"
import AstalNotifd from "gi://AstalNotifd"
import Gio from "gi://Gio?version=2.0"
import GLib from "gi://GLib"
import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import { SPACING, formatUnixTime } from "../../helpers"
import { fileExists } from "../../helpers/files"

const NOTIFICATION_SIZE=600

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
					{notification.image && fileExists(notification.image) && (
						<Adw.Clamp maximumSize={128}>
							<Gtk.Picture
								class="app-picture"
								valign={Gtk.Align.CENTER}
								contentFit={Gtk.ContentFit.SCALE_DOWN}
								file={Gio.File.new_for_path(notification.image)}
							/>
						</Adw.Clamp>
					)}
					{notification.image && isIcon(notification.image) && (
						<box valign={Gtk.Align.CENTER} halign={Gtk.Align.START} class="app-icon">
							<image
								iconName={notification.image}
								iconSize={Gtk.IconSize.LARGE}
								halign={Gtk.Align.CENTER}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					{!notification.image && notification.appIcon && isIcon(notification.appIcon) && (
						<box valign={Gtk.Align.CENTER} halign={Gtk.Align.START} class="app-icon">
							<image
								iconName={notification.appIcon}
								iconSize={Gtk.IconSize.LARGE}
								halign={Gtk.Align.CENTER}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					{!notification.image && notification.appIcon && fileExists(notification.appIcon) && (
						<Adw.Clamp maximumSize={128}>
							<Gtk.Picture
								class="app-picture"
								valign={Gtk.Align.CENTER}
								contentFit={Gtk.ContentFit.SCALE_DOWN}
								file={Gio.File.new_for_path(notification.appIcon)}
							/>
						</Adw.Clamp>
					)}
					{!notification.image && notification.desktopEntry && isIcon(notification.desktopEntry) && (
						<box valign={Gtk.Align.CENTER} halign={Gtk.Align.START} class="app-icon">
							<image
								iconName={notification.desktopEntry}
								iconSize={Gtk.IconSize.LARGE}
								halign={Gtk.Align.START}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					{((notification.image && (fileExists(notification.image) || isIcon(notification.appIcon))) ||
						(notification.appIcon && (fileExists(notification.appIcon) || isIcon(notification.appIcon))) ||
						(notification.desktopEntry && isIcon(notification.desktopEntry))) && (
						<Gtk.Separator orientation={Gtk.Orientation.VERTICAL} cssClasses={["spacer"]} />
					)}
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
								label={safeBody(notification.body)}
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

function safeBody(body: string): string {
	const [ok] = Pango.parse_markup(body, -1, "\0")
	return ok ? body : GLib.markup_escape_text(body, -1)
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
