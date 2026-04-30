export function lazy<T>(factory: () => T): () => T {
	let cache: { value: T } | undefined
	return () => (cache ??= { value: factory() }).value
}
