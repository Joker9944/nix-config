import GLib from "gi://GLib";

export function formatDateTime(
	dateTime: GLib.DateTime,
	format: string,
): string {
	return dateTime.format(format)!;
}

export function formatPercentage(utilization: number): string {
	if (utilization < 0) return "  -%";
	return `${Math.round(utilization)}%`.padStart(4, " ");
}

const DECIMAL_PLACES = 1;
const MAX_PADDING_LENGTH = 12;

const BIT_TO_KIBIBITS = 1024;
const BIT_TO_MEBIBITS = 1048576;
const BIT_TO_GIBIBITS = 1073741824;

export function formatSpeed(speed: number): string {
	if (speed < 0) return "-".padStart(MAX_PADDING_LENGTH, " ");
	if (speed < BIT_TO_KIBIBITS) {
		return `${speed.toFixed(DECIMAL_PLACES)}   b/s`.padStart(
			MAX_PADDING_LENGTH,
			" ",
		);
	} else if (speed < BIT_TO_MEBIBITS) {
		return `${(speed / BIT_TO_KIBIBITS).toFixed(
			DECIMAL_PLACES,
		)} Kib/s`.padStart(MAX_PADDING_LENGTH, " ");
	} else if (speed < BIT_TO_GIBIBITS) {
		return `${(speed / BIT_TO_MEBIBITS).toFixed(
			DECIMAL_PLACES,
		)} Mib/s`.padStart(MAX_PADDING_LENGTH, " ");
	} else {
		return `${(speed / BIT_TO_GIBIBITS).toFixed(
			DECIMAL_PLACES,
		)} Gib/s`.padStart(MAX_PADDING_LENGTH, " ");
	}
}
