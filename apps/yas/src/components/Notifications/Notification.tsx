import { Gdk } from "ags/gtk4";



import AstalNotifd from "gi://AstalNotifd";
import GdkPixbuf from "gi://GdkPixbuf";
import Gtk from "gi://Gtk?version=4.0";
import Pango from "gi://Pango";



import { SPACING, formatUnixTime } from "../../helpers";
import { fileExists } from "../../helpers/files";









































































































const IMAGE_SIZE_MAX = 128

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
					<Gtk.Picture
						class="app-picture"
						valign={Gtk.Align.CENTER}
						contentFit={Gtk.ContentFit.SCALE_DOWN}
						$={(self) => self.set_pixbuf(scaleImage(notification.image))}
					/>
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
					<Gtk.Picture
						class="app-picture"
						valign={Gtk.Align.CENTER}
						contentFit={Gtk.ContentFit.SCALE_DOWN}
						$={(self) => self.set_pixbuf(scaleImage(notification.appIcon))}
					/>
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

function scaleImage(path: string): GdkPixbuf.Pixbuf {
	const pixbuf = GdkPixbuf.Pixbuf.new_from_file(path)
	if (pixbuf.get_width() > IMAGE_SIZE_MAX || pixbuf.get_height() > IMAGE_SIZE_MAX) {
		const scale = IMAGE_SIZE_MAX / Math.max(pixbuf.get_width(), pixbuf.get_height())
		return pixbuf.scale_simple(
			Math.round(pixbuf.get_width() * scale),
			Math.round(pixbuf.get_height() * scale),
			GdkPixbuf.InterpType.BILINEAR, // cSpell:ignore Interp
		)!
	} else {
		return pixbuf
	}
}
