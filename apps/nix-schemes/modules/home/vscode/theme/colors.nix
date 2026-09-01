/**
  The workbench color table, mapped from a scheme.

  Slot roles follow tinted-theming/tinted-vscode's `base24.mustache`: `base11` is the
  deepest chrome and every border, `base10` the chrome above it, `base00` the editor and
  anything flush with it, `base01` selection, and `base02` at partial alpha every hover.
  `accent` stands in for `base0E` wherever the reference uses it as a UI highlight.

  # Type

  ```
  colors :: { palette, accent, ansi, status, hex, fade } -> { <color-key> :: string }
  ```
*/
{
  palette,
  accent,
  ansi,
  status,
  hex,
  fade,
}:
{
  foreground = hex palette.base05;
  disabledForeground = hex palette.base03;
  descriptionForeground = hex palette.base03;
  errorForeground = hex status.error;
  focusBorder = hex palette.base03;
  contrastBorder = hex palette.base11;
  "selection.background" = hex palette.base0D;
  "icon.foreground" = hex palette.base05;
  "sash.hoverBorder" = hex accent;
  "widget.border" = hex palette.base11;
  "widget.shadow" = hex palette.base11;
  "scrollbar.shadow" = hex palette.base11;
  "scrollbarSlider.background" = fade "50" palette.base02;
  "scrollbarSlider.hoverBackground" = fade "75" palette.base02;
  "scrollbarSlider.activeBackground" = fade "90" palette.base02;

  "textLink.foreground" = hex palette.base0C;
  "textLink.activeForeground" = hex palette.base15;
  "textBlockQuote.background" = hex palette.base10;
  "textBlockQuote.border" = hex palette.base11;
  "textCodeBlock.background" = hex palette.base10;
  "textPreformat.foreground" = hex palette.base0C;
  "textPreformat.background" = hex palette.base10;
  "textSeparator.foreground" = hex palette.base03;

  "button.background" = hex palette.base10;
  "button.foreground" = hex palette.base05;
  "button.border" = hex palette.base11;
  "button.hoverBackground" = hex palette.base01;
  "button.secondaryBackground" = hex palette.base00;
  "button.secondaryForeground" = hex palette.base05;
  "button.secondaryHoverBackground" = hex palette.base01;
  "checkbox.background" = hex palette.base10;
  "checkbox.foreground" = hex palette.base05;
  "checkbox.border" = hex palette.base11;

  "dropdown.background" = hex palette.base00;
  "dropdown.listBackground" = hex palette.base00;
  "dropdown.foreground" = hex palette.base05;
  "dropdown.border" = hex palette.base11;

  "input.background" = hex palette.base00;
  "input.foreground" = hex palette.base05;
  "input.border" = hex palette.base11;
  "input.placeholderForeground" = hex palette.base03;
  "inputOption.activeBackground" = fade "10" palette.base0D;
  "inputOption.activeForeground" = hex palette.base05;
  "inputOption.activeBorder" = hex palette.base0D;
  "inputValidation.infoForeground" = hex status.info;
  "inputValidation.infoBackground" = hex palette.base00;
  "inputValidation.infoBorder" = hex status.info;
  "inputValidation.warningForeground" = hex status.warning;
  "inputValidation.warningBackground" = hex palette.base00;
  "inputValidation.warningBorder" = hex status.warning;
  "inputValidation.errorForeground" = hex status.error;
  "inputValidation.errorBackground" = hex palette.base00;
  "inputValidation.errorBorder" = hex status.error;

  "badge.background" = hex palette.base01;
  "badge.foreground" = hex palette.base05;
  "progressBar.background" = hex accent;

  "list.activeSelectionBackground" = hex palette.base01;
  "list.activeSelectionForeground" = hex palette.base05;
  "list.inactiveSelectionBackground" = fade "75" palette.base02;
  "list.inactiveSelectionForeground" = hex palette.base05;
  "list.hoverBackground" = fade "75" palette.base02;
  "list.hoverForeground" = hex palette.base05;
  "list.focusBackground" = fade "75" palette.base02;
  "list.focusForeground" = hex palette.base05;
  "list.highlightForeground" = hex palette.base0C;
  "list.errorForeground" = hex status.error;
  "list.warningForeground" = hex status.warning;
  "list.dropBackground" = hex palette.base01;
  "listFilterWidget.background" = hex palette.base00;
  "listFilterWidget.outline" = hex palette.base01;
  "listFilterWidget.noMatchesOutline" = hex status.error;
  "tree.indentGuidesStroke" = hex palette.base03;
  "tree.inactiveIndentGuidesStroke" = fade "75" palette.base02;

  "activityBar.background" = hex palette.base00;
  "activityBar.foreground" = hex palette.base05;
  "activityBar.inactiveForeground" = hex palette.base03;
  "activityBar.activeBorder" = fade "80" accent;
  "activityBar.activeBackground" = fade "10" palette.base0D;
  "activityBarBadge.background" = hex accent;
  "activityBarBadge.foreground" = hex palette.base00;

  "sideBar.background" = hex palette.base10;
  "sideBar.foreground" = hex palette.base05;
  "sideBarTitle.foreground" = hex palette.base05;
  "sideBarSectionHeader.background" = hex palette.base00;
  "sideBarSectionHeader.foreground" = hex palette.base05;
  "sideBarSectionHeader.border" = hex palette.base11;

  "minimap.background" = hex palette.base00;
  "minimap.findMatchHighlight" = fade "80" palette.base09;
  "minimap.selectionHighlight" = hex palette.base01;
  "minimap.errorHighlight" = hex status.error;
  "minimap.warningHighlight" = hex status.warning;
  "minimapSlider.background" = fade "50" palette.base02;
  "minimapSlider.hoverBackground" = fade "75" palette.base02;
  "minimapSlider.activeBackground" = fade "90" palette.base02;
  "minimapGutter.addedBackground" = fade "80" palette.base0B;
  "minimapGutter.modifiedBackground" = fade "80" palette.base0C;
  "minimapGutter.deletedBackground" = fade "80" palette.base08;

  "editorGroup.border" = hex palette.base0D;
  "editorGroup.dropBackground" = fade "70" palette.base02;
  "editorGroupHeader.noTabsBackground" = hex palette.base11;
  "editorGroupHeader.tabsBackground" = hex palette.base11;
  "editorGroupHeader.tabsBorder" = hex palette.base11;

  "tab.activeBackground" = hex palette.base00;
  "tab.activeForeground" = hex palette.base05;
  "tab.activeBorderTop" = fade "80" accent;
  "tab.inactiveBackground" = hex palette.base10;
  "tab.inactiveForeground" = hex palette.base03;
  "tab.border" = hex palette.base11;
  "tab.hoverBackground" = fade "75" palette.base02;
  "tab.hoverForeground" = hex palette.base05;
  "tab.unfocusedActiveForeground" = hex palette.base03;
  "tab.unfocusedInactiveForeground" = hex palette.base03;
  "tab.lastPinnedBorder" = hex palette.base11;

  "editor.background" = hex palette.base00;
  "editor.foreground" = hex palette.base05;
  "editorLineNumber.foreground" = hex palette.base03;
  "editorLineNumber.activeForeground" = hex palette.base05;
  "editorCursor.foreground" = hex accent;
  "editorCursor.background" = hex palette.base00;
  "editor.selectionBackground" = hex palette.base01;
  "editor.selectionHighlightBackground" = hex palette.base01;
  "editor.inactiveSelectionBackground" = fade "75" palette.base02;
  "editor.wordHighlightBackground" = fade "50" palette.base0C;
  "editor.wordHighlightStrongBackground" = fade "50" palette.base0B;
  "editor.findMatchBackground" = fade "80" palette.base09;
  "editor.findMatchHighlightBackground" = fade "40" palette.base07;
  "editor.findRangeHighlightBackground" = fade "75" palette.base02;
  "editor.hoverHighlightBackground" = hex palette.base11;
  "editor.lineHighlightBorder" = hex palette.base01;
  "editor.rangeHighlightBackground" = fade "15" palette.base0D;
  "editor.foldBackground" = hex palette.base10;
  "editor.snippetTabstopHighlightBackground" = hex palette.base00;
  "editor.snippetTabstopHighlightBorder" = hex palette.base03;
  "editor.snippetFinalTabstopHighlightBackground" = hex palette.base00;
  "editor.snippetFinalTabstopHighlightBorder" = hex palette.base0B;
  "editorLink.activeForeground" = hex palette.base0C;
  "editorWhitespace.foreground" = fade "1A" palette.base07;
  "editorIndentGuide.background1" = fade "1A" palette.base07;
  "editorIndentGuide.activeBackground1" = fade "45" palette.base07;
  "editorRuler.foreground" = fade "1A" palette.base07;
  "editorCodeLens.foreground" = hex palette.base03;
  "editorGhostText.foreground" = hex palette.base03;
  "editorLightBulb.foreground" = hex palette.base09;
  "editorLightBulbAutoFix.foreground" = hex palette.base0B;
  "editorBracketMatch.background" = fade "75" palette.base02;
  "editorBracketMatch.border" = hex palette.base03;
  "editorStickyScroll.background" = hex palette.base00;
  "editorStickyScrollHover.background" = fade "75" palette.base02;

  "editorBracketHighlight.foreground1" = hex palette.base05;
  "editorBracketHighlight.foreground2" = hex palette.base0E;
  "editorBracketHighlight.foreground3" = hex palette.base0C;
  "editorBracketHighlight.foreground4" = hex palette.base0B;
  "editorBracketHighlight.foreground5" = hex palette.base0D;
  "editorBracketHighlight.foreground6" = hex palette.base09;
  "editorBracketHighlight.unexpectedBracket.foreground" = hex status.error;

  "editorError.foreground" = hex status.error;
  "editorWarning.foreground" = hex status.warning;
  "editorInfo.foreground" = hex status.info;
  "editorHint.foreground" = hex palette.base0C;

  "editorGutter.background" = hex palette.base00;
  "editorGutter.addedBackground" = fade "80" palette.base0B;
  "editorGutter.modifiedBackground" = fade "80" palette.base0C;
  "editorGutter.deletedBackground" = fade "80" palette.base08;
  "editorGutter.commentRangeForeground" = hex palette.base03;

  "editorOverviewRuler.border" = hex palette.base11;
  "editorOverviewRuler.findMatchForeground" = hex palette.base09;
  "editorOverviewRuler.rangeHighlightForeground" = fade "75" palette.base02;
  "editorOverviewRuler.selectionHighlightForeground" = hex palette.base09;
  "editorOverviewRuler.wordHighlightForeground" = hex palette.base0C;
  "editorOverviewRuler.wordHighlightStrongForeground" = hex palette.base0B;
  "editorOverviewRuler.bracketMatchForeground" = hex palette.base03;
  "editorOverviewRuler.addedForeground" = fade "80" palette.base0B;
  "editorOverviewRuler.modifiedForeground" = fade "80" palette.base0C;
  "editorOverviewRuler.deletedForeground" = fade "80" palette.base08;
  "editorOverviewRuler.errorForeground" = fade "80" status.error;
  "editorOverviewRuler.warningForeground" = fade "80" status.warning;
  "editorOverviewRuler.infoForeground" = fade "80" status.info;
  "editorOverviewRuler.currentContentForeground" = hex palette.base0B;
  "editorOverviewRuler.incomingContentForeground" = hex palette.base0D;

  "diffEditor.insertedTextBackground" = fade "20" palette.base0B;
  "diffEditor.removedTextBackground" = fade "50" palette.base08;
  "diffEditor.insertedLineBackground" = fade "15" palette.base0B;
  "diffEditor.removedLineBackground" = fade "25" palette.base08;
  "diffEditor.border" = hex palette.base11;
  "diffEditor.diagonalFill" = fade "75" palette.base02;

  "merge.currentHeaderBackground" = fade "90" palette.base0B;
  "merge.currentContentBackground" = fade "40" palette.base0B;
  "merge.incomingHeaderBackground" = fade "90" palette.base0D;
  "merge.incomingContentBackground" = fade "40" palette.base0D;
  "merge.commonHeaderBackground" = fade "90" palette.base03;
  "merge.commonContentBackground" = fade "40" palette.base03;

  "editorWidget.background" = hex palette.base10;
  "editorWidget.foreground" = hex palette.base05;
  "editorWidget.border" = hex palette.base11;
  "editorWidget.resizeBorder" = hex accent;
  "editorSuggestWidget.background" = hex palette.base10;
  "editorSuggestWidget.foreground" = hex palette.base05;
  "editorSuggestWidget.border" = hex palette.base11;
  "editorSuggestWidget.selectedBackground" = hex palette.base01;
  "editorSuggestWidget.selectedForeground" = hex palette.base05;
  "editorSuggestWidget.highlightForeground" = hex palette.base0C;
  "editorSuggestWidget.focusHighlightForeground" = hex palette.base0C;
  "editorHoverWidget.background" = hex palette.base00;
  "editorHoverWidget.foreground" = hex palette.base05;
  "editorHoverWidget.border" = hex palette.base03;
  "editorHoverWidget.statusBarBackground" = hex palette.base01;
  "editorMarkerNavigation.background" = hex palette.base10;

  "peekView.border" = hex palette.base01;
  "peekViewEditor.background" = hex palette.base00;
  "peekViewEditor.matchHighlightBackground" = fade "80" palette.base13;
  "peekViewEditorGutter.background" = hex palette.base00;
  "peekViewResult.background" = hex palette.base10;
  "peekViewResult.fileForeground" = hex palette.base05;
  "peekViewResult.lineForeground" = hex palette.base05;
  "peekViewResult.matchHighlightBackground" = fade "80" palette.base13;
  "peekViewResult.selectionBackground" = hex palette.base01;
  "peekViewResult.selectionForeground" = hex palette.base05;
  "peekViewTitle.background" = hex palette.base11;
  "peekViewTitleLabel.foreground" = hex palette.base05;
  "peekViewTitleDescription.foreground" = hex palette.base03;

  "panel.background" = hex palette.base00;
  "panel.border" = hex palette.base0D;
  "panel.dropBorder" = hex accent;
  "panelInput.border" = hex palette.base11;
  "panelTitle.activeBorder" = hex accent;
  "panelTitle.activeForeground" = hex palette.base05;
  "panelTitle.inactiveForeground" = hex palette.base03;
  "panelSection.border" = hex palette.base11;
  "panelSectionHeader.background" = hex palette.base10;

  "statusBar.background" = hex palette.base11;
  "statusBar.foreground" = hex palette.base05;
  "statusBar.debuggingBackground" = hex palette.base08;
  "statusBar.debuggingForeground" = hex palette.base11;
  "statusBar.noFolderBackground" = hex palette.base11;
  "statusBar.noFolderForeground" = hex palette.base05;
  "statusBarItem.activeBackground" = fade "90" palette.base02;
  "statusBarItem.hoverBackground" = fade "75" palette.base02;
  "statusBarItem.prominentBackground" = hex palette.base08;
  "statusBarItem.prominentHoverBackground" = hex palette.base09;
  "statusBarItem.remoteBackground" = hex palette.base0D;
  "statusBarItem.remoteForeground" = hex palette.base00;
  "statusBarItem.errorBackground" = hex status.error;
  "statusBarItem.errorForeground" = hex palette.base00;
  "statusBarItem.warningBackground" = hex status.warning;
  "statusBarItem.warningForeground" = hex palette.base00;

  "titleBar.activeBackground" = hex palette.base10;
  "titleBar.activeForeground" = hex palette.base05;
  "titleBar.inactiveBackground" = hex palette.base11;
  "titleBar.inactiveForeground" = hex palette.base03;

  "menubar.selectionBackground" = fade "75" palette.base02;
  "menubar.selectionForeground" = hex palette.base05;
  "menu.background" = hex palette.base10;
  "menu.foreground" = hex palette.base05;
  "menu.border" = hex palette.base11;
  "menu.selectionBackground" = hex palette.base01;
  "menu.selectionForeground" = hex palette.base05;
  "menu.separatorBackground" = hex palette.base11;

  "notificationCenter.border" = hex palette.base10;
  "notificationCenterHeader.background" = hex palette.base00;
  "notificationCenterHeader.foreground" = hex palette.base05;
  "notificationToast.border" = hex palette.base10;
  "notifications.background" = hex palette.base00;
  "notifications.foreground" = hex palette.base05;
  "notifications.border" = hex palette.base10;
  "notificationLink.foreground" = hex palette.base0C;
  "notificationsErrorIcon.foreground" = hex status.error;
  "notificationsWarningIcon.foreground" = hex status.warning;
  "notificationsInfoIcon.foreground" = hex status.info;

  "banner.background" = hex palette.base01;
  "banner.foreground" = hex palette.base05;
  "banner.iconForeground" = hex status.info;

  "quickInput.background" = hex palette.base10;
  "quickInput.foreground" = hex palette.base05;
  "quickInputList.focusBackground" = hex palette.base01;
  "quickInputList.focusForeground" = hex palette.base05;
  "quickInputTitle.background" = hex palette.base11;
  "pickerGroup.border" = hex palette.base0D;
  "pickerGroup.foreground" = hex palette.base0C;

  "keybindingLabel.background" = hex palette.base01;
  "keybindingLabel.foreground" = hex palette.base05;
  "keybindingLabel.border" = hex palette.base11;
  "keybindingLabel.bottomBorder" = hex palette.base11;

  "terminal.background" = hex palette.base00;
  "terminal.foreground" = hex palette.base05;
  "terminal.border" = hex palette.base11;
  "terminal.selectionBackground" = fade "50" palette.base01;
  "terminalCursor.foreground" = hex accent;
  "terminalCursor.background" = hex palette.base00;
  "terminal.ansiBlack" = hex ansi."0";
  "terminal.ansiRed" = hex ansi."1";
  "terminal.ansiGreen" = hex ansi."2";
  "terminal.ansiYellow" = hex ansi."3";
  "terminal.ansiBlue" = hex ansi."4";
  "terminal.ansiMagenta" = hex ansi."5";
  "terminal.ansiCyan" = hex ansi."6";
  "terminal.ansiWhite" = hex ansi."7";
  "terminal.ansiBrightBlack" = hex ansi."8";
  "terminal.ansiBrightRed" = hex ansi."9";
  "terminal.ansiBrightGreen" = hex ansi."A";
  "terminal.ansiBrightYellow" = hex ansi."B";
  "terminal.ansiBrightBlue" = hex ansi."C";
  "terminal.ansiBrightMagenta" = hex ansi."D";
  "terminal.ansiBrightCyan" = hex ansi."E";
  "terminal.ansiBrightWhite" = hex ansi."F";

  "gitDecoration.addedResourceForeground" = hex palette.base0B;
  "gitDecoration.modifiedResourceForeground" = hex palette.base0C;
  "gitDecoration.deletedResourceForeground" = hex palette.base08;
  "gitDecoration.renamedResourceForeground" = hex palette.base0C;
  "gitDecoration.untrackedResourceForeground" = hex palette.base0B;
  "gitDecoration.ignoredResourceForeground" = hex palette.base03;
  "gitDecoration.conflictingResourceForeground" = hex palette.base09;
  "gitDecoration.stageModifiedResourceForeground" = hex palette.base15;
  "gitDecoration.stageDeletedResourceForeground" = hex palette.base12;
  "gitDecoration.submoduleResourceForeground" = hex palette.base0E;

  "breadcrumb.background" = hex palette.base00;
  "breadcrumb.foreground" = hex palette.base03;
  "breadcrumb.focusForeground" = hex palette.base05;
  "breadcrumb.activeSelectionForeground" = hex palette.base05;
  "breadcrumbPicker.background" = hex palette.base11;

  "settings.headerForeground" = hex palette.base05;
  "settings.modifiedItemIndicator" = hex palette.base09;
  "settings.focusedRowBackground" = fade "75" palette.base02;
  "settings.dropdownBackground" = hex palette.base10;
  "settings.dropdownForeground" = hex palette.base05;
  "settings.dropdownBorder" = hex palette.base11;
  "settings.checkboxBackground" = hex palette.base10;
  "settings.checkboxForeground" = hex palette.base05;
  "settings.checkboxBorder" = hex palette.base11;
  "settings.textInputBackground" = hex palette.base10;
  "settings.textInputForeground" = hex palette.base05;
  "settings.textInputBorder" = hex palette.base11;
  "settings.numberInputBackground" = hex palette.base10;
  "settings.numberInputForeground" = hex palette.base05;
  "settings.numberInputBorder" = hex palette.base11;

  "debugToolBar.background" = hex palette.base10;
  "debugToolBar.border" = hex palette.base11;
  "editor.stackFrameHighlightBackground" = fade "20" palette.base09;
  "editor.focusedStackFrameHighlightBackground" = fade "20" palette.base0B;
  "debugIcon.breakpointForeground" = hex status.error;
  "debugIcon.breakpointDisabledForeground" = hex palette.base03;
  "debugConsoleInputIcon.foreground" = hex accent;
  "debugConsole.infoForeground" = hex status.info;
  "debugConsole.warningForeground" = hex status.warning;
  "debugConsole.errorForeground" = hex status.error;
  "debugConsole.sourceForeground" = hex palette.base03;

  "testing.iconPassed" = hex status.success;
  "testing.iconFailed" = hex status.error;
  "testing.iconErrored" = hex status.error;
  "testing.iconQueued" = hex status.warning;
  "testing.iconSkipped" = hex palette.base03;
  "testing.iconUnset" = hex palette.base03;

  "problemsErrorIcon.foreground" = hex status.error;
  "problemsWarningIcon.foreground" = hex status.warning;
  "problemsInfoIcon.foreground" = hex status.info;

  "extensionButton.prominentForeground" = hex palette.base05;
  "extensionButton.prominentBackground" = fade "90" status.success;
  "extensionButton.prominentHoverBackground" = fade "60" status.success;
  "extensionBadge.remoteBackground" = hex accent;
  "extensionBadge.remoteForeground" = hex palette.base00;
  "extensionIcon.starForeground" = hex palette.base09;
  "extensionIcon.verifiedForeground" = hex status.success;
  "extensionIcon.preReleaseForeground" = hex palette.base0E;

  "welcomePage.buttonBackground" = hex palette.base01;
  "welcomePage.buttonHoverBackground" = fade "75" palette.base02;
  "walkThrough.embeddedEditorBackground" = hex palette.base10;
}
