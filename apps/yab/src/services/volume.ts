import AstalWp from "gi://AstalWp"
import { createBinding } from "ags"

export const { defaultSpeaker: defaultSpeaker, audio: audio } =
	AstalWp.get_default()

export const defaultSpeakerVolumeIconAccessor = createBinding(
	defaultSpeaker,
	"volumeIcon"
)
export const defaultSpeakerVolumeAccessor = createBinding(
	defaultSpeaker,
	"volume"
)
export const defaultSpeakerMuteAccessor = createBinding(defaultSpeaker, "mute")
export const speakersAccessor = createBinding(audio, "speakers")
