import Gtk from "gi://Gtk"
import AstalWp from "gi://AstalWp"
import { Module } from "./Module"
import {
	defaultSpeaker,
	defaultSpeakerMuteAccessor,
	defaultSpeakerVolumeAccessor,
	defaultSpeakerVolumeIconAccessor,
	speakersAccessor,
} from "../../services/volume"
import { For } from "ags"
import { formatPercentage } from "../../helpers/formatters"
import { SPACING } from "../../helpers/constants"

export default function Volume() {
	return (
		<Module name="volume">
			<menubutton>
				<box>
					<image iconName={defaultSpeakerVolumeIconAccessor} />
					<label cssName="value" cssClasses={["font-mono"]} label={volume} />
				</box>
				<popover hasArrow={false}>
					<box spacing={SPACING.NORMAL} orientation={Gtk.Orientation.VERTICAL}>
						<box>
							<button
								cssClasses={[
									"p-1",
									"m-0",
									"rounded-full",
									"min-width-8",
									"min-height-8",
								]}
								onClicked={() =>
									defaultSpeaker.set_mute(!defaultSpeaker.get_mute())
								}
							>
								<image iconName={muteButtonIcon} />
							</button>
							<slider
								widthRequest={260}
								onChangeValue={({ value }) => defaultSpeaker.set_volume(value)}
								value={defaultSpeakerVolumeAccessor}
							/>
						</box>
						<box
							cssClasses={["p-4", "rounded-2xl", "base-background"]}
							spacing={SPACING.TIGHT}
							orientation={Gtk.Orientation.VERTICAL}
						>
							<For each={speakersAccessor}>
								{(speaker) => (
									<button
										cssClasses={speakerButtonCssClasses(speaker)}
										onClicked={() => speaker.set_is_default(true)}
									>
										<label label={speakerLabel(speaker)} />
									</button>
								)}
							</For>
						</box>
					</box>
				</popover>
			</menubutton>
		</Module>
	)
}

const volume = defaultSpeakerVolumeAccessor.as((volume) =>
	formatPercentage(volume * 100)
)

const muteButtonIcon = defaultSpeakerMuteAccessor.as((mute) => {
	return mute ? "audio-volume-off" : "audio-volume-high"
})

function speakerLabel(speaker: AstalWp.Endpoint) {
	return speaker.get_description() ?? speaker.get_id().toString()
}

function speakerButtonCssClasses(speaker: AstalWp.Endpoint) {
	return defaultSpeaker.get_id() === speaker.get_id() ? [] : ["inactive"]
}
