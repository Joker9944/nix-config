import Gio from "gi://Gio"
import { Accessor } from "ags"
import { createPoll } from "ags/time"

const DISK_USAGE_QUERY = `${Gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE},${Gio.FILE_ATTRIBUTE_FILESYSTEM_USED}`

const disks = new Map<string, Accessor<number>>()

class Disk {
	readonly file: Gio.File

	constructor(path: string) {
		this.file = Gio.File.new_for_path(path)
	}

	usage(): number {
		const info = this.file.query_filesystem_info(DISK_USAGE_QUERY, null)

		const size = info.get_attribute_uint64(Gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE)
		const used = info.get_attribute_uint64(Gio.FILE_ATTRIBUTE_FILESYSTEM_USED)

		return (used / size) * 100
	}
}

export default function accessorFromPath(path: string): Accessor<number> {
	let accessor = disks.get(path)
	if (!accessor) {
		const disc = new Disk(path)
		accessor = createPoll(-1, 10000, () => disc.usage())
		disks.set(path, accessor)
	}
	return accessor
}
