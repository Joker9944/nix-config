import GLib from "gi://GLib"

const CONFIG_PATH = `${GLib.get_user_config_dir()}/yab/config.json`

type Config = {
	gpu?: boolean,
	battery?: boolean,
}

function loadConfig(): Config {
	if (!GLib.file_test(CONFIG_PATH, GLib.FileTest.EXISTS)) return {}

	const [success, data] = GLib.file_get_contents(CONFIG_PATH)
	if (!success) return {}

	return parseConfig(new TextDecoder().decode(data))
}

function parseConfig(config: string): Config {
	try {
		return JSON.parse(config)
	} catch (e) {
		console.error("Could not parse config", e)
		return {}
	}
}

const config = loadConfig()

export const showGpu = config.gpu !== undefined && config.gpu
export const showBattery = config.battery !== undefined && config.battery
