import { Module } from "./Module"
import {
	focusedWorkspaceAccessor,
	focusWorkspace,
	isSpecial,
	specialWorkspaceName,
	workspacesAccessor,
} from "../../../services/workspaces"
import { Accessor, For } from "ags";
import AstalHyprland from "gi://AstalHyprland"
import { SPACING } from "../../../helpers"

type WorkspacesProps = {
	connector: string
}

export default function Workspaces({ connector }: WorkspacesProps): JSX.Element {
	return (
		<Module name="workspaces" spacing={SPACING.TIGHT}>
			<For each={filterWorkspaces(connector)}>
				{(workspace) => (
					<button
						onClicked={() => focusWorkspace(workspace)}
						cssClasses={workspaceButtonCssClasses(workspace)}
					>
						{isSpecial(workspace) ? (
							<image
								cssClasses={["font-2xl"]}
								iconName={specialWorkspaceName(workspace)!}
							/>
						) : (
							<label
								cssName="value"
								cssClasses={["font-mono"]}
								label={workspace.get_name()}
							/>
						)}
					</button>
				)}
			</For>
		</Module>
	)
}

function filterWorkspaces(
	connector: string,
): Accessor<AstalHyprland.Workspace[]> {
	return workspacesAccessor.as((workspaces) => {
		return workspaces
			.filter((workspace) => {
				return (
					(workspace.get_monitor().get_name() ?? null) === connector ||
					isSpecial(workspace)
				)
			})
			.sort((a, b) => a.get_id() - b.get_id())
	})
}

function workspaceButtonCssClasses(
	workspace: AstalHyprland.Workspace,
): Accessor<string[]> {
	return focusedWorkspaceAccessor.as((focusedWorkspace) => {
		const focusClasses =
			focusedWorkspace != null && // even when focusedWorkspace should never be null it can be during waking from sleep
			focusedWorkspace.get_id() === workspace.get_id()
				? ["selected"]
				: ["inactive"]
		return ["p-1", "m-0", "rounded-full", "min-width-8", "min-height-8"].concat(
			focusClasses,
		)
	})
}
