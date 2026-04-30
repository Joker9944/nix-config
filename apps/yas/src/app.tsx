import { For, This, createBinding } from "ags"
import app from "ags/gtk4/app"

import Bar from "./components/Bar"
import Notifications from "./components/Notifications"
import style from "./styles/main.scss"

app.start({
	css: style,
	main() {
		const monitors = createBinding(app, "monitors")

		return (
			<For each={monitors}>
				{(monitor) => (
					<This this={app}>
						<Bar gdkmonitor={monitor} />
						<Notifications gdkmonitor={monitor} />
					</This>
				)}
			</For>
		)
	},
})
