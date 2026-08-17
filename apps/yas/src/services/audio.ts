import { createBinding } from "ags"

import AstalWp from "gi://AstalWp"

import { lazyAccessor } from "../helpers"

const wp = AstalWp.get_default()

export const defaultSpeakerVolumeIconAccessor = lazyAccessor(() => {
	return createBinding(wp, "defaultSpeaker", "volumeIcon")
})

export const defaultSpeakerVolumeAccessor = lazyAccessor(() => {
	return createBinding(wp, "defaultSpeaker", "volume")
})

export const defaultSpeakerMuteAccessor = lazyAccessor(() => {
	return createBinding(wp, "defaultSpeaker", "mute")
})

export const speakersAccessor = lazyAccessor(() => {
	return createBinding(wp, "audio", "speakers").as((speakers) => speakers ?? [])
})

export const defaultSpeakerAccessor = lazyAccessor(() => {
	return createBinding(wp, "defaultSpeaker")
})

export function toggleDefaultSpeakerMute(): void {
	const speaker = wp.get_default_speaker()
	speaker.set_mute(!speaker.get_mute())
}

export function setDefaultSpeakerVolume(volume: number): void {
	wp.get_default_speaker().set_volume(volume)
}

export function setDefaultSpeaker(speaker: AstalWp.Endpoint): void {
	speaker.set_is_default(true)
}
