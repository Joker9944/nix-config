import AstalBattery from "gi://AstalBattery";
import {createBinding} from "ags";
import { lazyAccessor } from "../helpers"

const battery = AstalBattery.get_default()

export const batteryIconAccessor = lazyAccessor(() => {
	return createBinding(battery, "batteryIconName")
})

export const percentageAccessor = lazyAccessor(() => {
	return createBinding(battery, "percentage")
})
