import { createPoll } from "ags/time"

import AstalNetwork from "gi://AstalNetwork"
import GTop from "gi://GTop"
import NM from "gi://NM?version=1.0"

import { exponentialMovingAverage, lazyAccessor } from "../helpers"

type Snapshot = {
	networkInterface: string | null
	rx: number
	tx: number
	timestamp: number
}

export type Speed = {
	down: number
	up: number
}

const netload = new GTop.glibtop_netload()
const network = AstalNetwork.get_default()

function primaryNetworkInterface(): string | null {
	return primaryNetworkDevice()?.get_iface() ?? null
}

function primaryNetworkDevice(): NM.Device | null {
	switch (network.get_primary()) {
		case AstalNetwork.Primary.WIRED:
			return network.get_wired()?.get_device() ?? null
		case AstalNetwork.Primary.WIFI:
			return network.get_wifi()?.get_device() ?? null
		case AstalNetwork.Primary.UNKNOWN:
		default:
			return null
	}
}

function snapshot(): Snapshot {
	const networkInterface = primaryNetworkInterface()
	const timestamp = Date.now()

	if (networkInterface === null) return { networkInterface, rx: 0, tx: 0, timestamp }

	GTop.glibtop_get_netload(netload, networkInterface)
	return {
		networkInterface,
		rx: netload.bytes_in * 8,
		tx: netload.bytes_out * 8,
		timestamp,
	}
}

let previousSnapshot: Snapshot

let smoothingDown = exponentialMovingAverage()
let smoothingUp = exponentialMovingAverage()

function speed(): Speed {
	const currentSnapshot = snapshot()

	// Counters are per interface, so a delta spanning a switch is meaningless and the averages carry the old link
	if (currentSnapshot.networkInterface !== previousSnapshot.networkInterface) {
		previousSnapshot = currentSnapshot
		smoothingDown = exponentialMovingAverage()
		smoothingUp = exponentialMovingAverage()
		return { down: -1, up: -1 }
	}

	if (currentSnapshot.networkInterface === null) return { down: -1, up: -1 }

	const deltaTime = (currentSnapshot.timestamp - previousSnapshot.timestamp) / 1000

	const speed = {
		down: smoothingDown((currentSnapshot.rx - previousSnapshot.rx) / deltaTime),
		up: smoothingUp((currentSnapshot.tx - previousSnapshot.tx) / deltaTime),
	}

	previousSnapshot = currentSnapshot

	return speed
}

export const speedAccessor = lazyAccessor(() => {
	previousSnapshot = snapshot()
	return createPoll<Speed>({ down: -1, up: -1 }, 1000, () => speed())
})
