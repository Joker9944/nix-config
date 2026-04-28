import Gio from "gi://Gio"
import { createPoll } from "ags/time"
import { memoize } from "../helpers"

const DISK_USAGE_QUERY = `${Gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE},${Gio.FILE_ATTRIBUTE_FILESYSTEM_USED}`

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

export const utilizationAccessor = memoize((path: string) => {
	const disk = new Disk(path)
	return createPoll(-1, 10000, () => disk.usage())
})
