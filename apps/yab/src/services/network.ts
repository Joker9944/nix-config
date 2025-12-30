import GTop from "gi://GTop"
import AstalNetwork from "gi://AstalNetwork"
import NM from "gi://NM?version=1.0"
import { createPoll } from "ags/time"
import { movingAverage } from "../helpers/smoothing"

type Snapshot = {
	rx: number
	tx: number
	timestamp: number
}

export type Speed = {
	down: number
	up: number
}

const netload = new GTop.glibtop_netload()
const {
	primary: primaryDevice,
	wired: wired,
	wifi: wifi,
} = AstalNetwork.get_default()

function primaryNetworkInterface(): string | null {
	return primaryNetworkDevice()?.get_iface() ?? null
}

function primaryNetworkDevice(): NM.Device | null {
	switch (primaryDevice) {
		case AstalNetwork.Primary.WIRED:
			return wired.get_device()
		case AstalNetwork.Primary.WIFI:
			return wifi.get_device()
		case AstalNetwork.Primary.UNKNOWN:
			return null
	}
}

function snapshot(networkInterface: string): Snapshot {
	GTop.glibtop_get_netload(netload, networkInterface)
	return {
		rx: netload.bytes_in * 8,
		tx: netload.bytes_out * 8,
		timestamp: Date.now(),
	}
}

function primarySnapshot(): Snapshot {
	const networkInterface = primaryNetworkInterface()
	return networkInterface
		? snapshot(networkInterface)
		: { rx: 0, tx: 0, timestamp: Date.now() }
}

let previousSnapshot = { rx: 0, tx: 0, timestamp: Date.now() }

const smoothingDown = movingAverage(3)
const smoothingUp = movingAverage(3)

function speed(): Speed {
	const currentSnapshot = primarySnapshot()
	const deltaTime =
		(currentSnapshot.timestamp - previousSnapshot.timestamp) / 1000

	const speed = {
		down: smoothingDown((currentSnapshot.rx - previousSnapshot.rx) / deltaTime),
		up: smoothingUp((currentSnapshot.tx - previousSnapshot.tx) / deltaTime),
	}

	previousSnapshot = currentSnapshot

	return speed
}

export const speedAccessor = createPoll<Speed>({ down: -1, up: -1 }, 1000, () =>
	speed()
)
