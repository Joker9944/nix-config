import AstalWp from "gi://AstalWp"
import { createBinding } from "ags"
import { lazyAccessor } from "../helpers"

export const { defaultSpeaker: defaultSpeaker, audio: audio } =
	AstalWp.get_default()

export const defaultSpeakerVolumeIconAccessor = lazyAccessor(() => {
	return createBinding(defaultSpeaker, "volumeIcon")
})

export const defaultSpeakerVolumeAccessor = lazyAccessor(() => {
	return createBinding(defaultSpeaker, "volume")
})

export const defaultSpeakerMuteAccessor = lazyAccessor(() => {
	return createBinding(defaultSpeaker, "mute")
})

export const speakersAccessor = lazyAccessor(() => {
	return createBinding(audio, "speakers")
})

export const defaultSpeakerAccessor = lazyAccessor(() => {
	return createBinding(audio, "defaultSpeaker")
})
