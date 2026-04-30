export function memoize<K, T>(factory: (key: K) => T): (key: K) => T {
	const cache = new Map<K, T>()
	return (key) => {
		if (!cache.has(key)) cache.set(key, factory(key))
		return cache.get(key)!
	}
}

export function weakMemoize<K extends WeakKey, T>(factory: (key: K) => T): (key: K) => T {
	const cache = new WeakMap<K, T>()
	return (key) => {
		if (!cache.has(key)) cache.set(key, factory(key))
		return cache.get(key)!
	}
}
