import { Accessor } from "ags"
import { SPACING } from "../../helpers/constants"

type ModuleProps = {
	name: string
	cssClasses?: string[]
	spacing?: number
	children: any
}

export function Module({
	name,
	cssClasses = [],
	spacing = SPACING.TIGHT,
	children,
}: ModuleProps) {
	return (
		<box cssName="module" name={name} cssClasses={cssClasses} spacing={spacing}>
			{children}
		</box>
	)
}

type StatModuleProps = {
	name: string
	cssClasses?: string[]
	spacing?: number
	label: string
	value: string | Accessor<string>
}

export function StatModule({
	name,
	cssClasses,
	spacing,
	label,
	value,
}: StatModuleProps) {
	return (
		<Module name={name} cssClasses={cssClasses} spacing={spacing}>
			<label cssClasses={["font-bold"]} label={label} />
			<label cssName="value" cssClasses={["font-mono"]} label={value} />
		</Module>
	)
}
