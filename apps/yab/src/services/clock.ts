import GLib from "gi://GLib"
import { createPoll } from "ags/time"
import { lazyAccessor } from "../helpers"

function now(): GLib.DateTime {
	return GLib.DateTime.new_now_local()
}

export const nowAccessor = lazyAccessor(() => {
	return createPoll(now(), 1000, () => now())
})
