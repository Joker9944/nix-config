import Gtk from "gi://Gtk"
import AstalWp from "gi://AstalWp"
import { Module } from "./Module"
import {
	defaultSpeaker,
	defaultSpeakerAccessor,
	defaultSpeakerMuteAccessor,
	defaultSpeakerVolumeAccessor,
	defaultSpeakerVolumeIconAccessor,
	speakersAccessor,
} from "../../../services/audio"
import { formatPercentage, SPACING } from "../../../helpers";
import { Accessor, createComputed, For } from "ags";

export default function Audio(): JSX.Element {
	return (
		<Module name="volume" spacing={SPACING.NONE}>
			<menubutton>
				<box spacing={SPACING.TIGHT}>
					<image iconName={defaultSpeakerVolumeIconAccessor} />
					<label
						cssName="value"
						cssClasses={["font-mono", "font-normal"]}
						label={volume}
					/>
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
								hexpand={true}
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

const volume = createComputed(() =>
	defaultSpeakerMuteAccessor()
		? "  -%"
		: formatPercentage(defaultSpeakerVolumeAccessor() * 100),
)

const muteButtonIcon = defaultSpeakerMuteAccessor.as((mute) =>
	mute ? "audio-volume-off" : "audio-volume-high",
)

function speakerLabel(speaker: AstalWp.Endpoint) {
	return speaker.get_description() ?? speaker.get_id().toString()
}

function speakerButtonCssClasses(speaker: AstalWp.Endpoint): Accessor<string[]> {
	return defaultSpeakerAccessor.as((defaultSpeaker) =>
		defaultSpeaker.get_id() === speaker.get_id() ? [] : ["inactive"]
	)
}
