import Pango from "gi://Pango"

export type Body = { text: string; markup: boolean }

// Pango.parse_markup throws rather than reporting failure, and rejects the <a href> that GtkLabel itself accepts
export function isMarkup(body: string): boolean {
	try {
		Pango.parse_markup(body, -1, "\0")
		return true
	} catch {
		return false
	}
}

export function escapeAmpersands(body: string): string {
	return body.replace(/&(?!(#[0-9]+|#x[0-9a-fA-F]+|amp|lt|gt|quot|apos);)/g, "&amp;")
}

export function toPlainText(body: string): string {
	return body
		.replace(/<[^>]*>/g, "")
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&quot;/g, '"')
		.replace(/&apos;/g, "'")
		.replace(/&amp;/g, "&")
}

export function resolveBody(body: string): Body {
	if (isMarkup(body)) return { text: body, markup: true }

	const escaped = escapeAmpersands(body)
	if (isMarkup(escaped)) return { text: escaped, markup: true }

	return { text: toPlainText(body), markup: false }
}
