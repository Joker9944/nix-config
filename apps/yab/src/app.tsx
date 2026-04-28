import style from "./styles/main.scss";
import Bar from "./components/Bar";
import { createBinding, For, This } from "ags";
import app from "ags/gtk4/app";

app.start({
	css: style,
	main() {
		const monitors = createBinding(app, "monitors");

		return (
			<For each={monitors}>
				{(monitor) => (
					<This this={app}>
						<Bar gdkmonitor={monitor} />
					</This>
				)}
			</For>
		);
	},
});
