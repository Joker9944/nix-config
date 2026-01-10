import AstalBattery from "gi://AstalBattery";
import {createBinding} from "ags";

const battery = AstalBattery.get_default()

export const percentageAccessor = createBinding(battery, "percentage")
