import AstalHyprland from "gi://AstalHyprland"
import { createBinding } from "ags"

const hyprland = AstalHyprland.get_default()

export const workspaces = createBinding(hyprland, "workspaces")
export const focusedWorkspace = createBinding(hyprland, "focused_workspace")

export function focusWorkspace(workspace: AstalHyprland.Workspace): void {
	if (hyprland.get_focused_workspace().get_id() === workspace.get_id()) {
		// Workspace is already focused -> nothing to do
		return
	}

	if (!isSpecial(workspace)) {
		workspace.focus()
	} else {
		hyprland.dispatch(
			"togglespecialworkspace", // cSpell:ignore togglespecialworkspace
			specialWorkspaceName(workspace)!
		)
	}
}

export function isSpecial(workspace: AstalHyprland.Workspace): boolean {
	return workspace.get_name().startsWith("special")
}

export function specialWorkspaceName(
	workspace: AstalHyprland.Workspace
): string | null {
	return workspace.get_name().split(":").at(1) ?? null
}
