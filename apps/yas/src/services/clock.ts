import { createPoll } from "ags/time"

import GLib from "gi://GLib"

import { lazyAccessor } from "../helpers"

function now(): GLib.DateTime {
	return GLib.DateTime.new_now_local()
}

export const nowAccessor = lazyAccessor(() => {
	return createPoll(now(), 1000, () => now())
})
