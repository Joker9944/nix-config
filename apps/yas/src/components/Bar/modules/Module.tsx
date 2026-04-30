import { Accessor } from "ags";



import { SPACING } from "../../../helpers";

























































































type ModuleProps = {
	name: string
	cssClasses?: string[]
	spacing?: number
	children: JSX.Element | JSX.Element[]
}

export function Module({ name, cssClasses = [], spacing = SPACING.TIGHT, children }: ModuleProps): JSX.Element {
	return (
		<box cssName={name} cssClasses={["module", ...cssClasses]} spacing={spacing}>
			{children}
		</box>
	)
}

type LabelStatModuleProps = {
	name: string
	cssClasses?: string[]
	spacing?: number
	label: string
	value: string | Accessor<string>
}

export function LabelStatModule({ name, cssClasses, spacing, label, value }: LabelStatModuleProps): JSX.Element {
	return (
		<Module name={name} cssClasses={cssClasses} spacing={spacing}>
			<label cssClasses={["heading"]} label={label} />
			<label cssName="value" cssClasses={["monospace"]} label={value} />
		</Module>
	)
}

type IconStatModuleProps = {
	name: string
	cssClasses?: string[]
	spacing?: number
	icon: string | Accessor<string>
	value: string | Accessor<string>
}

export function IconStatModule({ name, cssClasses, spacing, icon, value }: IconStatModuleProps): JSX.Element {
	return (
		<Module name={name} cssClasses={cssClasses} spacing={spacing}>
			<image iconName={icon} />
			<label cssName="value" cssClasses={["monospace"]} label={value} />
		</Module>
	)
}
