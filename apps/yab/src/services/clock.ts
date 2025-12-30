import GLib from "gi://GLib"
import { createPoll } from "ags/time"

function now(): GLib.DateTime {
	return GLib.DateTime.new_now_local()
}

export const nowAccessor = createPoll(now(), 1000, () => now())
