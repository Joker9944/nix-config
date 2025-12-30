import GLib from "gi://GLib"

export function formatDateTime(
	dateTime: GLib.DateTime,
	format: string
): string {
	return dateTime.format(format)!
}

export function formatPercentage(utilization: number): string {
	return `${Math.round(utilization)}%`.padStart(4, " ")
}
