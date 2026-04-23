import app from "ags/gtk4/app"
import { Gdk } from "ags/gtk4"
import style from "./src/styles.scss"
import Bar from "./src/widget/Bar"

const bars = new Map<Gdk.Monitor, ReturnType<typeof Bar>>()

function addBar(monitor: Gdk.Monitor) {
	if (bars.has(monitor)) return
	bars.set(monitor, Bar(monitor))
}

function destroyBar(monitor: Gdk.Monitor) {
	const bar = bars.get(monitor)
	if (bar) {
		bar.destroy()
		bars.delete(monitor)
	}
}

app.start({
	css: style,
	main() {
		const display = Gdk.Display.get_default()
		if (!display) throw Error("could not get display")
		display.get_monitors().connect("items-changed", () => {
			const current = app.get_monitors()
			for (const monitor of bars.keys())
				if (!current.includes(monitor)) destroyBar(monitor)
			current.forEach(addBar)
		})

		app.get_monitors().forEach(addBar)
	},
})
