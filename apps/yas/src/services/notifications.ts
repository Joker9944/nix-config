import { createBinding, createState } from "ags"

import AstalNotifd from "gi://AstalNotifd"
import GLib from "gi://GLib"

import { lazy, lazyAccessor } from "../helpers"

const DEFAULT_TIMEOUT = 10000

const notifd = lazy(() => AstalNotifd.get_default())

export const staticNotificationsAccessor = lazyAccessor(() => {
	const [notifications, setNotifications] = createState(new Array<AstalNotifd.Notification>())

	// initialize with past notifications
	setNotifications(() => notifd().get_notifications())

	notifd().connect("notified", (_, id, replaced) => {
		const notification = notifd().get_notification(id)!

		if (replaced && notifications.peek().some((n) => n.id === id)) {
			setNotifications((ns) => ns.map((n) => (n.id === id ? notification : n)))
		} else {
			setNotifications((ns) => [notification, ...ns])
		}
	})

	notifd().connect("resolved", (_, id) => {
		setNotifications((ns) => ns.filter((n) => n.id !== id))
	})

	return notifications
})

export const timeoutNotificationsAccessor = lazyAccessor(() => {
	const [notifications, setNotifications] = createState(new Array<AstalNotifd.Notification>())
	const timers = new Map<number, number>()

	notifd().connect("notified", (_, id, replaced) => {
		const notification = notifd().get_notification(id)!

		if (replaced && notifications.peek().some((n) => n.id === id)) {
			const existingTimer = timers.get(id)
			if (existingTimer !== undefined) {
				GLib.Source.remove(existingTimer)
				timers.delete(id)
			}
			setNotifications((ns) => ns.map((n) => (n.id === id ? notification : n)))
		} else {
			setNotifications((ns) => [notification, ...ns])
		}

		const timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, determineTimeout(notification), () => {
			timers.delete(id)
			setNotifications((ns) => ns.filter((n) => n.id !== id))
			return GLib.SOURCE_REMOVE
		})
		timers.set(id, timer)
	})

	notifd().connect("resolved", (_, id) => {
		const existingTimer = timers.get(id)
		if (existingTimer !== undefined) {
			GLib.Source.remove(existingTimer)
			timers.delete(id)
		}
		setNotifications((ns) => ns.filter((n) => n.id !== id))
	})

	return notifications
})

function determineTimeout(notification: AstalNotifd.Notification): number {
	if (notification.expireTimeout < 0) return DEFAULT_TIMEOUT
	return notification.expireTimeout
}

export const dontDisturbAccessor = lazyAccessor(() => {
	return createBinding(notifd(), "dontDisturb")
})
