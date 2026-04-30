import { For, createComputed } from "ags"

import AstalWp from "gi://AstalWp"
import Gtk from "gi://Gtk?version=4.0"

import { SPACING, formatPercentage, lazyAccessor, weakMemoize } from "../../../helpers"
import {
	defaultSpeaker,
	defaultSpeakerAccessor,
	defaultSpeakerMuteAccessor,
	defaultSpeakerVolumeAccessor,
	defaultSpeakerVolumeIconAccessor,
	speakersAccessor,
} from "../../../services/audio"
import { IconStatModule, Module } from "./Module"

export default function Audio(): JSX.Element {
	return (
		<Module name="volume" spacing={SPACING.NONE}>
			<menubutton>
				<box spacing={SPACING.TIGHT}>
					<image iconName={defaultSpeakerVolumeIconAccessor} />
					<label cssName="value" cssClasses={["monospace"]} label={volume} />
				</box>
				<popover hasArrow={false} $={(self) => self.set_offset(0, SPACING.NORMAL)}>
					<box spacing={SPACING.NORMAL} orientation={Gtk.Orientation.VERTICAL}>
						<box>
							<button class="circular" onClicked={() => defaultSpeaker.set_mute(!defaultSpeaker.get_mute())}>
								<image iconName={muteButtonIcon} />
							</button>
							<slider
								hexpand={true}
								onChangeValue={({ value }) => defaultSpeaker.set_volume(value)}
								value={defaultSpeakerVolumeAccessor}
							/>
						</box>
						<box cssClasses={["base-background"]} spacing={SPACING.TIGHT} orientation={Gtk.Orientation.VERTICAL}>
							<For each={speakersAccessor}>
								{(speaker) => (
									<button
										cssClasses={speakerButtonCssAccessors(speaker)}
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

const volume = lazyAccessor(() => {
	return createComputed(() => {
		return defaultSpeakerMuteAccessor() ? "  -%" : formatPercentage(defaultSpeakerVolumeAccessor() * 100)
	})
})

const muteButtonIcon = lazyAccessor(() => {
	return defaultSpeakerMuteAccessor.as((mute) => {
		return mute ? "audio-volume-off" : "audio-volume-high"
	})
})

function speakerLabel(speaker: AstalWp.Endpoint) {
	return speaker.get_description() ?? speaker.get_id().toString()
}

const speakerButtonCssAccessors = weakMemoize((speaker: AstalWp.Endpoint) => {
	return defaultSpeakerAccessor.as((defaultSpeaker) =>
		defaultSpeaker.get_id() === speaker.get_id() ? [] : ["inactive"],
	)
})
