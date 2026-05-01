import { Accessor, For } from "ags"

import AstalHyprland from "gi://AstalHyprland"

import { SPACING } from "../../../helpers"
import {
	focusWorkspace,
	focusedWorkspaceAccessor,
	isSpecial,
	specialWorkspaceName,
	workspacesAccessor,
} from "../../../services/workspaces"
import { Module } from "./Module"


type WorkspacesProps = {
	connector: string
}

export default function Workspaces({ connector }: WorkspacesProps): JSX.Element {
	return (
		<Module name="workspaces" spacing={SPACING.TIGHT}>
			<For each={filterWorkspaces(connector)}>
				{(workspace) => (
					<button onClicked={() => focusWorkspace(workspace)} cssClasses={workspaceButtonCssClasses(workspace)}>
						{isSpecial(workspace) ? (
							// TODO add check if this an actual icon
							<image class="app-icon" iconName={specialWorkspaceName(workspace)!} />
						) : (
							<label cssName="value" label={workspace.get_name()} />
						)}
					</button>
				)}
			</For>
		</Module>
	)
}

function filterWorkspaces(connector: string): Accessor<AstalHyprland.Workspace[]> {
	return workspacesAccessor.as((workspaces) => {
		return workspaces
			.filter((workspace) => {
				return (workspace.get_monitor().get_name() ?? null) === connector || isSpecial(workspace)
			})
			.sort((a, b) => a.get_id() - b.get_id())
	})
}

function workspaceButtonCssClasses(workspace: AstalHyprland.Workspace): Accessor<string[]> {
	return focusedWorkspaceAccessor.as((focusedWorkspace) => {
		const classes = ["circular", "monospace", "numeric"]
		if (focusedWorkspace != null && focusedWorkspace.get_id() === workspace.get_id()) classes.push("suggested-action")
		return classes
	})
}
