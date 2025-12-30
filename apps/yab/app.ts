import app from "ags/gtk4/app"
import style from "./src/styles.scss"
import Bar from "./src/widget/Bar"

app.start({
	css: style,
	main() {
		app.get_monitors().map(Bar)
	},
})
